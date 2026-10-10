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
  // personId → 参与的全部家庭（按输入顺序），多配偶布局的基础
  final marriagesOf = <String, List<String>>{};
  // 家庭 → 伴侣对（保持 partner1/partner2 顺序）
  final partnersOf = <String, List<String>>{};
  for (final f in input.families) {
    final partners = [f.partner1Id, f.partner2Id].whereType<String>().toList();
    if (partners.isEmpty) continue;
    partnersOf[f.id] = partners;
    for (final p in partners) {
      marriagesOf.putIfAbsent(p, () => []).add(f.id);
    }
  }

  final placed = <String>{}; // 已进入某个单元的人
  final units = <_Unit>[];

  _Unit buildUnit(String anchorId, int depth) {
    final unit = _Unit(anchorId, depth);
    placed.add(anchorId);

    final leftSeq = <String>[]; // 内→外
    final rightSeq = <String>[]; // 内→外
    final usedFamilies = <String>{};

    String? freeSpouseOf(String fid, String self) {
      for (final p in partnersOf[fid] ?? const <String>[]) {
        if (p != self && !placed.contains(p) && byId.containsKey(p)) {
          return p;
        }
      }
      return null;
    }

    // 展开成员的其余婚姻：新配偶放到其更外侧，并递归继续
    // （配偶链：前任—本人—现任—… 每对夫妻相邻，横杆短且清晰）
    void expand(String pid, bool left) {
      for (final fid in marriagesOf[pid] ?? const <String>[]) {
        if (!usedFamilies.add(fid)) continue;
        final spouse = freeSpouseOf(fid, pid);
        if (spouse == null) continue;
        placed.add(spouse);
        if (left) {
          leftSeq.add(spouse);
        } else {
          rightSeq.add(spouse);
        }
        expand(spouse, left);
      }
    }

    // 锚点婚姻：第一任左、第二任右、交替向外
    var mi = 0;
    for (final fid in marriagesOf[anchorId] ?? const <String>[]) {
      usedFamilies.add(fid);
      final spouse = freeSpouseOf(fid, anchorId);
      if (spouse != null) {
        placed.add(spouse);
        if (mi.isEven) {
          leftSeq.add(spouse);
        } else {
          rightSeq.add(spouse);
        }
      }
      mi++;
    }
    for (final s in leftSeq.toList()) {
      expand(s, true);
    }
    for (final s in rightSeq.toList()) {
      expand(s, false);
    }

    unit.members
      ..addAll(leftSeq.reversed)
      ..add(anchorId)
      ..addAll(rightSeq);

    // 子女槽位按各家庭「夫妻对中点」的显示位置排序，
    // 单亲家庭挂在本人位——保证子女挂在对应婚姻下方、减少连线交叉
    final idx = <String, int>{
      for (var i = 0; i < unit.members.length; i++) unit.members[i]: i,
    };
    final keyed = <MapEntry<double, String>>[];
    for (final fid in usedFamilies) {
      final partners =
          (partnersOf[fid] ?? const <String>[]).where(idx.containsKey);
      if (partners.isEmpty) continue;
      var sum = 0.0;
      for (final p in partners) {
        sum += idx[p]!;
      }
      keyed.add(MapEntry(sum / partners.length, fid));
    }
    keyed.sort((a, b) => a.key.compareTo(b.key));
    for (final e in keyed) {
      for (final childId in childrenOf[e.value] ?? const <String>[]) {
        if (placed.contains(childId)) continue;
        if (!byId.containsKey(childId)) continue;
        unit.children.add(buildUnit(childId, depth + 1));
      }
    }
    return unit;
  }

  // 根：以「根家庭」为组件锚点 —— 夫妻双方都没有父母家庭的才做根
  // （最老一代），其余人由父母单元向下收编，保证父母代显示在子女上方。
  // 之前只按人物列表顺序收编，本人先入列时其父母会被平铺成同级独立根。
  for (final f in input.families) {
    // 只统计在谱（未删除）的伴侣：幽灵家庭（成员均已删除）
    // 不得建单元、不得抢走子女——否则子女会被挂到看不见的节点下
    final partners = (partnersOf[f.id] ?? const <String>[])
        .where(byId.containsKey)
        .toList();
    if (partners.isEmpty) continue;
    final isRootFamily =
        partners.every((p) => !parentFamilyOf.containsKey(p));
    if (!isRootFamily) continue;
    String? anchor;
    for (final p in partners) {
      if (!placed.contains(p)) {
        anchor = p;
        break;
      }
    }
    if (anchor == null) continue; // 双方均已随其他单元布局
    units.add(buildUnit(anchor, 0));
  }
  // 兜底：无家庭归属、或父母链接悬空（父母不在谱）的人
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
        spouseOf: pid == u.anchorId ? null : u.anchorId,
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
    final partnerIds =
        [f.partner1Id, f.partner2Id].whereType<String>().toList();
    final partners =
        partnerIds.where(nodeRects.containsKey).toList();
    // 父母全部不在谱（已删除）：孩子另有归属，不画悬空连线
    if (partnerIds.isNotEmpty && partners.isEmpty) continue;
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
    // 母线覆盖锚点 x 与子女跨度——单子女时从锚点到孩子，避免 L 断开
    final busLeft = math.min(anchor.dx, kidCenters.first.dx);
    final busRight = math.max(anchor.dx, kidCenters.last.dx);
    wires.add(WireSegment(Offset(busLeft, busY), Offset(busRight, busY)));
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
