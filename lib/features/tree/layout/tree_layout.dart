/// 树布局引擎 —— 规划文档阶段 1 交付项。
///
/// 采用「家庭单元」(family unit) 为节点的 Reingold–Tilford 轮廓布局：
/// - 夫妻/伴侣并排为一个单元；子女挂在父母单元下方（正交连线）。
/// - ⚠️ 函数签名显式接收 [TextDirection]（规划文档 6.6 坑 #1）：
///   布局在 LTR 逻辑空间计算，RTL 时整体镜像，避免事后补 RTL 返工。
/// - 后续可升级为 Buchheim–Walker（线性时间），当前轮廓法对 MVP 规模足够。
library;

import 'dart:math' as math;
import 'dart:ui';

import '../../../data/db/app_database.dart';

const double kNodeW = 112;
const double kNodeH = 68;
const double kCoupleGap = 28; // 夫妻节点间距
const double kSiblingGap = 36; // 单元（兄弟姐妹）间距
const double kRowPitch = 130; // 代际行距
const double kRootGap = 80; // 无关联家系之间的间距

class LaidOutNode {
  LaidOutNode({
    required this.person,
    required this.rect,
    required this.generation,
    required this.isFocus,
    required this.isSelf,
    this.spouseOf, // 同单元伴侣（画横杆用）
  });

  final Person person;
  final Rect rect;
  final int generation;
  final bool isFocus;
  final bool isSelf;
  final String? spouseOf;
}

/// 一条正交连线段（世界坐标）。
class WireSegment {
  const WireSegment(this.from, this.to);
  final Offset from;
  final Offset to;
}

class TreeLayoutResult {
  const TreeLayoutResult({
    required this.nodes,
    required this.wires,
    required this.bounds,
  });

  final List<LaidOutNode> nodes;
  final List<WireSegment> wires;
  final Rect bounds;

  LaidOutNode? nodeAt(Offset worldPoint) {
    for (final n in nodes.reversed) {
      if (n.rect.contains(worldPoint)) return n;
    }
    return null;
  }
}

class TreeLayoutInput {
  const TreeLayoutInput({
    required this.persons,
    required this.families,
    required this.childLinks,
    required this.textDirection,
    this.focusPersonId,
  });

  final List<Person> persons;
  final List<Family> families;
  final List<FamilyChildLink> childLinks;
  final TextDirection textDirection;
  final String? focusPersonId;
}

/// ---------- 家庭单元 ----------

class _Unit {
  _Unit(this.anchorId, this.depth);

  final String anchorId;
  final int depth; // 代际：根单元 = 0，向下一代 +1
  final List<String> members = []; // anchor + spouse
  final List<_Unit> children = [];
  // 布局中间量（相对父单元左缘的 x）
  double placeX = 0;
  double absX = 0;
  final Map<int, double> leftContour = {};
  final Map<int, double> rightContour = {};

  double get width =>
      members.length * kNodeW + (members.length - 1) * kCoupleGap;
}

TreeLayoutResult computeTreeLayout(TreeLayoutInput input) {
  if (input.persons.isEmpty) {
    return TreeLayoutResult(
      nodes: const [],
      wires: const [],
      bounds: Rect.zero,
    );
  }

  final byId = {for (final p in input.persons) p.id: p};

  // personId → 作为孩子的家庭
  final parentFamilyOf = <String, String>{};
  // 家庭 → 孩子（按 sortOrder）
  final childrenOf = <String, List<String>>{};
  for (final link in input.childLinks) {
    parentFamilyOf.putIfAbsent(link.personId, () => link.familyId);
    childrenOf.putIfAbsent(link.familyId, () => []).add(link.personId);
  }
  // personId → 作为伴侣参与的第一个家庭
  final partnerFamilyOf = <String, String>{};
  // 家庭 → 伴侣对（保持 partner1/partner2 顺序）
  final partnersOf = <String, List<String>>{};
  for (final f in input.families) {
    final partners = [f.partner1Id, f.partner2Id].whereType<String>().toList();
    if (partners.isEmpty) continue;
    partnersOf[f.id] = partners;
    for (final p in partners) {
      partnerFamilyOf.putIfAbsent(p, () => f.id);
    }
  }

  final placed = <String>{}; // 已进入某个单元的人
  final units = <_Unit>[];

  _Unit buildUnit(String anchorId, int depth) {
    final unit = _Unit(anchorId, depth);
    placed.add(anchorId);
    unit.members.add(anchorId);
    // 伴侣并入同一单元（MVP：取其参与的第一个家庭）
    final famId = partnerFamilyOf[anchorId];
    String? spouseId;
    if (famId != null) {
      for (final p in partnersOf[famId] ?? const <String>[]) {
        if (p != anchorId && !placed.contains(p)) {
          spouseId = p;
          break;
        }
      }
    }
    if (spouseId != null) {
      placed.add(spouseId);
      unit.members.add(spouseId);
    }
    // 该单元的家庭 = anchor(或 anchor+spouse) 的家庭（有孩子的优先）
    final familyIds = <String>{
      if (famId != null) famId,
      if (spouseId != null && partnerFamilyOf[spouseId] != null)
        partnerFamilyOf[spouseId]!,
    };
    for (final fid in familyIds) {
      for (final childId in childrenOf[fid] ?? const <String>[]) {
        if (placed.contains(childId)) continue; // 已随伴侣单元布局
        if (!byId.containsKey(childId)) continue;
        unit.children.add(buildUnit(childId, depth + 1));
      }
    }
    return unit;
  }

  // 根：所有未被单元收编的人（无父母家庭且未被当作配偶并入）
  for (final p in input.persons) {
    if (placed.contains(p.id)) continue;
    units.add(buildUnit(p.id, 0));
  }

  // ---------- 轮廓布局（后序测宽，前序定位） ----------
  void measure(_Unit u) {
    u.leftContour.clear();
    u.rightContour.clear();
    u.leftContour[u.depth] = 0;
    u.rightContour[u.depth] = u.width;

    if (u.children.isEmpty) return;

    final placedRights = <Map<int, double>>[];
    double runningX = 0;
    for (var i = 0; i < u.children.length; i++) {
      final c = u.children[i];
      measure(c);
      double x = 0;
      if (i > 0) {
        // 与所有已放置兄弟做轮廓分离
        double shift = runningX + kSiblingGap;
        for (final entry in c.leftContour.entries) {
          for (final pr in placedRights) {
            final prevRight = pr[entry.key];
            if (prevRight == null) continue;
            shift = math.max(shift, prevRight - entry.value + kSiblingGap);
          }
        }
        x = shift;
      }
      c.placeX = x;
      placedRights.add({
        for (final e in c.rightContour.entries) e.key: e.value + x,
      });
      runningX = x + c.width;
    }

    // 家长单元居中于子女跨度（原型视觉：子女对称挂在父母下方）
    final first = u.children.first;
    final last = u.children.last;
    final spanCenter = (first.placeX + last.placeX + last.width) / 2;
    final centeringShift = u.width / 2 - spanCenter;
    if (centeringShift != 0) {
      for (final c in u.children) {
        c.placeX += centeringShift;
      }
    }

    // 子女轮廓并入自身轮廓（相对自身左缘 0）
    for (final c in u.children) {
      c.leftContour.forEach((d, v) {
        final x = c.placeX + v;
        u.leftContour[d] = math.min(u.leftContour[d] ?? x, x);
      });
      c.rightContour.forEach((d, v) {
        final x = c.placeX + v;
        u.rightContour[d] = math.max(u.rightContour[d] ?? x, x);
      });
    }
  }

  void assign(_Unit u, double parentAbsX) {
    u.absX = parentAbsX + u.placeX;
    // 家长居中于子女跨度（在自身可行范围内微调：允许左移，不与兄弟冲突由轮廓保证）
    for (final c in u.children) {
      assign(c, u.absX);
    }
  }

  double cursorX = 0;
  final rootsX = <double>[];
  for (final root in units) {
    measure(root);
    root.placeX = cursorX;
    assign(root, 0);
    rootsX.add(root.absX);
    // 下一棵根树右移
    double maxRight = 0;
    root.rightContour.forEach((_, v) => maxRight = math.max(maxRight, v));
    cursorX = root.absX + maxRight + kRootGap;
  }

  // ---------- 生成输出 ----------
  Offset xform(double x, double y) {
    // RTL：世界坐标整体镜像（规划文档 6.6 坑 #1 的预埋点）
    if (input.textDirection == TextDirection.rtl) {
      return Offset(-x, y);
    }
    return Offset(x, y);
  }

  final nodes = <LaidOutNode>[];
  final nodeRects = <String, Rect>{};
  final wires = <WireSegment>[];

  Offset rectOrigin(_Unit u, int memberIndex, double unitAbsX) {
    final x = unitAbsX + memberIndex * (kNodeW + kCoupleGap);
    final y = u.depth * kRowPitch;
    final p = xform(x, y);
    return p;
  }

  void emit(_Unit u) {
    for (var i = 0; i < u.members.length; i++) {
      final pid = u.members[i];
      final person = byId[pid];
      if (person == null) continue;
      final origin = rectOrigin(u, i, u.absX);
      final rect = Rect.fromLTWH(origin.dx, origin.dy, kNodeW, kNodeH);
      nodeRects[pid] = rect;
      nodes.add(LaidOutNode(
        person: person,
        rect: rect,
        generation: u.depth,
        isFocus: input.focusPersonId == pid,
        isSelf: person.isSelf,
        spouseOf: i > 0 ? u.members.first : null,
      ));
    }
    for (final c in u.children) {
      emit(c);
    }
  }

  for (final root in units) {
    emit(root);
  }

  // ---------- 连线 ----------
  final center = (Rect r) => Offset(r.left + r.width / 2, r.top + r.height / 2);

  // 夫妻横杆
  for (final f in input.families) {
    final partners = [f.partner1Id, f.partner2Id]
        .whereType<String>()
        .where(nodeRects.containsKey)
        .toList();
    if (partners.length == 2) {
      final a = center(nodeRects[partners[0]]!);
      final b = center(nodeRects[partners[1]]!);
      wires.add(WireSegment(a, b));
    }
  }

  // 家庭 → 子女（正交：中点垂下 → 母线 → 分支垂到孩子头顶）
  for (final f in input.families) {
    final kids = (childrenOf[f.id] ?? const <String>[])
        .where(nodeRects.containsKey)
        .toList();
    if (kids.isEmpty) continue;
    final partners = [f.partner1Id, f.partner2Id]
        .whereType<String>()
        .where(nodeRects.containsKey)
        .toList();
    Offset anchor;
    if (partners.length == 2) {
      final a = nodeRects[partners[0]]!;
      final b = nodeRects[partners[1]]!;
      anchor = Offset((a.left + a.width / 2 + b.left + b.width / 2) / 2,
          a.top + a.height / 2);
    } else if (partners.length == 1) {
      final a = nodeRects[partners[0]]!;
      anchor = center(a);
    } else {
      // 无伴侣的单亲家庭：以第一个孩子上方为锚
      final k0 = center(nodeRects[kids.first]!);
      anchor = Offset(k0.dx, k0.dy - kRowPitch * 0.5);
    }
    final kidCenters =
        kids.map((k) => center(nodeRects[k]!)).toList()..sort((a, b) => a.dx.compareTo(b.dx));
    final firstKidTop = nodeRects[kids.first]!.top;
    final busY = anchor.dy + (firstKidTop - anchor.dy) * 0.45;
    wires.add(WireSegment(anchor, Offset(anchor.dx, busY)));
    wires.add(WireSegment(Offset(kidCenters.first.dx, busY),
        Offset(kidCenters.last.dx, busY)));
    for (final kc in kidCenters) {
      wires.add(WireSegment(Offset(kc.dx, busY), Offset(kc.dx, firstKidTop)));
    }
  }

  // bounds
  var bounds = Rect.zero;
  for (final n in nodes) {
    bounds = bounds.isEmpty ? n.rect : bounds.expandToInclude(n.rect);
  }
  for (final w in wires) {
    bounds = bounds.expandToInclude(Rect.fromPoints(w.from, w.to));
  }

  return TreeLayoutResult(nodes: nodes, wires: wires, bounds: bounds);
}
