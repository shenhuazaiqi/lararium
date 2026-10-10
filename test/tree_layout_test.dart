// 树布局引擎回归测试 —— 重点覆盖「父母代必须显示在子女代上方」。
// 回归背景：旧根选择按人物列表顺序取"未被收编者"，本人先入列时
// 其父母会被平铺成同代独立根（2026-10-10 用户报告）。
import 'dart:math' as math;

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tree/data/db/app_database.dart';
import 'package:tree/features/tree/layout/tree_layout.dart';

Person _p(String id, {bool self = false}) => Person(
      id: id,
      treeId: 't',
      givenName: id,
      surname: '',
      gender: 'unknown',
      birthPrecision: 'year',
      deathPrecision: 'year',
      isLiving: true,
      allowPublicLink: false,
      flowerCount: 0,
      candleCount: 0,
      incenseCount: 0,
      prayerCount: 0,
      messageCount: 0,
      isSelf: self,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

Family _f(String id, {String? p1, String? p2}) => Family(
      id: id,
      treeId: 't',
      partner1Id: p1,
      partner2Id: p2,
      relationType: 'couple',
      sortOrder: 0,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

FamilyChildLink _link(String familyId, String personId) => FamilyChildLink(
      familyId: familyId,
      treeId: 't',
      personId: personId,
      sortOrder: 0,
      pedigree: 'birth',
    );

int _genOf(TreeLayoutResult r, String personId) =>
    r.nodes.firstWhere((n) => n.person.id == personId).generation;

void main() {
  test('父母代在上：本人先入列表，父母仍为第 0 代（回归用例）', () {
    // persons 故意把 self 放最前 —— 旧算法会先收编 self 为根，
    // 导致其父母被平铺成同级独立根
    final persons = [
      _p('self', self: true),
      _p('father'),
      _p('mother'),
      _p('spouse'),
      _p('child'),
    ];
    final families = [
      _f('fParents', p1: 'father', p2: 'mother'),
      _f('fSelf', p1: 'self', p2: 'spouse'),
    ];
    final links = [
      _link('fParents', 'self'),
      _link('fSelf', 'child'),
    ];

    final r = computeTreeLayout(TreeLayoutInput(
      persons: persons,
      families: families,
      childLinks: links,
      textDirection: TextDirection.ltr,
      focusPersonId: 'self',
    ));

    expect(_genOf(r, 'father'), 0);
    expect(_genOf(r, 'mother'), 0);
    expect(_genOf(r, 'self'), 1);
    expect(_genOf(r, 'spouse'), 1);
    expect(_genOf(r, 'child'), 2);

    // 父母单元居中于子女单元正上方：两对夫妻的中点对齐
    Rect rectOf(String id) =>
        r.nodes.firstWhere((n) => n.person.id == id).rect;
    final parentsMid =
        (rectOf('father').center.dx + rectOf('mother').center.dx) / 2;
    final selfMid =
        (rectOf('self').center.dx + rectOf('spouse').center.dx) / 2;
    expect(parentsMid, closeTo(selfMid, 0.5));

    // 有父母家庭 → 本人的连线存在
    expect(r.wires, isNotEmpty);
  });

  test('多配偶：本人居中，两配偶分列两侧，各自子女挂对应侧', () {
    // mother 先后与 father1、father2 组建家庭；
    // father1 的孩子是 self，father2 的孩子是 kid2
    final persons = [
      _p('self', self: true),
      _p('kid2'),
      _p('mother'),
      _p('father1'),
      _p('father2'),
    ];
    final families = [
      _f('fM', p1: 'mother', p2: 'father1'),
      _f('fM2', p1: 'mother', p2: 'father2'),
    ];
    final links = [
      _link('fM', 'self'),
      _link('fM2', 'kid2'),
    ];

    final r = computeTreeLayout(TreeLayoutInput(
      persons: persons,
      families: families,
      childLinks: links,
      textDirection: TextDirection.ltr,
      focusPersonId: 'self',
    ));

    // 三人同为第 0 代，且全部被收编进同一个单元（不再各自为根）
    for (final id in ['mother', 'father1', 'father2']) {
      expect(_genOf(r, id), 0, reason: id);
    }
    expect(_genOf(r, 'self'), 1);
    expect(_genOf(r, 'kid2'), 1);
    expect(r.nodes.length, 5); // 无重复节点

    Rect rectOf(String id) =>
        r.nodes.firstWhere((n) => n.person.id == id).rect;
    // mother 居中：第一任 father1 在左、第二任 father2 在右，
    // 间距恰好一个单元位
    final m = rectOf('mother').center.dx;
    expect(rectOf('father1').center.dx, lessThan(m));
    expect(rectOf('father2').center.dx, greaterThan(m));
    expect(m - rectOf('father1').center.dx, 112 + 28); // kNodeW + kCoupleGap
    expect(rectOf('father2').center.dx - m, 112 + 28);

    // 各婚姻子女挂在对应配偶一侧：self（father1 之子）在左，kid2 在右
    expect(rectOf('self').center.dx, lessThan(m));
    expect(rectOf('kid2').center.dx, greaterThan(m));
  });

  test('多配偶且配偶带前序子女：前序子女挂在该配偶外侧', () {
    // father1 与前任（ex）有一子 kidEx，之后与 mother 组建家庭生 self
    final persons = [
      _p('self', self: true),
      _p('kidEx'),
      _p('mother'),
      _p('father1'),
      _p('ex'),
    ];
    final families = [
      _f('fEx', p1: 'father1', p2: 'ex'),
      _f('fM', p1: 'father1', p2: 'mother'),
    ];
    final links = [
      _link('fEx', 'kidEx'),
      _link('fM', 'self'),
    ];

    final r = computeTreeLayout(TreeLayoutInput(
      persons: persons,
      families: families,
      childLinks: links,
      textDirection: TextDirection.ltr,
    ));

    expect(r.nodes.length, 5); // 所有人都被收编，无重复
    for (final id in ['father1', 'ex', 'mother']) {
      expect(_genOf(r, id), 0, reason: id);
    }
    expect(_genOf(r, 'kidEx'), 1);
    expect(_genOf(r, 'self'), 1);

    Rect rectOf(String id) =>
        r.nodes.firstWhere((n) => n.person.id == id).rect;
    // father1 居中，ex 在左、mother 在右；各自子女挂在对应侧
    final f = rectOf('father1').center.dx;
    expect(rectOf('ex').center.dx, lessThan(f));
    expect(rectOf('mother').center.dx, greaterThan(f));
    expect(rectOf('kidEx').center.dx, lessThan(f));
    expect(rectOf('self').center.dx, greaterThan(f));
  });

  test('配偶链：给已布局的成员再加配偶，紧邻入链而非独立成根（回归用例）', () {
    // mother—father1 结婚生 self，mother—father2 再婚；
    // 之后 father1 又与 step 结婚（fNew 输入顺序靠后）
    final persons = [
      _p('self', self: true),
      _p('mother'),
      _p('father1'),
      _p('father2'),
      _p('step'),
    ];
    final families = [
      _f('fM', p1: 'mother', p2: 'father1'),
      _f('fM2', p1: 'mother', p2: 'father2'),
      _f('fNew', p1: 'father1', p2: 'step'),
    ];
    final links = [_link('fM', 'self')];

    final r = computeTreeLayout(TreeLayoutInput(
      persons: persons,
      families: families,
      childLinks: links,
      textDirection: TextDirection.ltr,
      focusPersonId: 'self',
    ));

    // 四个大人都收进同一单元（step 不再漂移成独立根），self 在下一代
    expect(r.nodes.length, 5);
    for (final id in ['mother', 'father1', 'father2', 'step']) {
      expect(_genOf(r, id), 0, reason: id);
    }
    expect(_genOf(r, 'self'), 1);

    Rect rectOf(String id) =>
        r.nodes.firstWhere((n) => n.person.id == id).rect;
    // step 紧贴 father1（相邻单元位），夫妻横杆短而清晰
    expect(
        (rectOf('father1').center.dx - rectOf('step').center.dx).abs(), 140);
  });

  test('单子女连线：母线从夫妻中点连到孩子头顶，不断开（回归用例）', () {
    // 旧算法母线 = 「第一孩子中心 → 最后孩子中心」，单孩子时零长度，
    // 夫妻对下的竖线与孩子头顶的竖线互不相连
    final persons = [_p('self', self: true), _p('father'), _p('mother')];
    final r = computeTreeLayout(TreeLayoutInput(
      persons: persons,
      families: [_f('fP', p1: 'father', p2: 'mother')],
      childLinks: [_link('fP', 'self')],
      textDirection: TextDirection.ltr,
    ));

    Rect rectOf(String id) =>
        r.nodes.firstWhere((n) => n.person.id == id).rect;
    final coupleMid =
        (rectOf('father').center.dx + rectOf('mother').center.dx) / 2;
    final kidCx = rectOf('self').center.dx;

    // 存在一条水平母线，x 范围同时覆盖夫妻中点与孩子中心，
    // 且 y 位于两代之间
    final hasConnectingBus = r.wires.any((w) =>
        w.from.dy == w.to.dy &&
        math.min(w.from.dx, w.to.dx) <= math.min(coupleMid, kidCx) &&
        math.max(w.from.dx, w.to.dx) >= math.max(coupleMid, kidCx) &&
        w.from.dy > rectOf('father').bottom &&
        w.from.dy < rectOf('self').top);
    expect(hasConnectingBus, isTrue,
        reason: '夫妻中点与孩子之间必须有连续的水平母线');
  });

  test('单亲家庭：单亲为第 0 代，子女为第 1 代', () {
    final r = computeTreeLayout(TreeLayoutInput(
      persons: [_p('kid'), _p('mom')],
      families: [_f('f1', p1: 'mom')],
      childLinks: [_link('f1', 'kid')],
      textDirection: TextDirection.ltr,
    ));
    expect(_genOf(r, 'mom'), 0);
    expect(_genOf(r, 'kid'), 1);
  });

  test('无关联家系：互不相连时并排为独立根', () {
    final r = computeTreeLayout(TreeLayoutInput(
      persons: [_p('a1'), _p('a2'), _p('b1'), _p('b2')],
      families: [
        _f('fa', p1: 'a1', p2: 'a2'),
        _f('fb', p1: 'b1', p2: 'b2'),
      ],
      childLinks: const [],
      textDirection: TextDirection.ltr,
    ));
    expect(_genOf(r, 'a1'), 0);
    expect(_genOf(r, 'b1'), 0);
    Rect rectOf(String id) =>
        r.nodes.firstWhere((n) => n.person.id == id).rect;
    // 两棵根树左右并排，不重叠
    expect(rectOf('b1').left, greaterThan(rectOf('a2').right));
  });

  test('三代同堂：祖辈 → 父辈 → 子辈 逐代下移', () {
    final r = computeTreeLayout(TreeLayoutInput(
      persons: [_p('kid2'), _p('mid1'), _p('mid2'), _p('top1'), _p('top2')],
      families: [
        _f('fTop', p1: 'top1', p2: 'top2'),
        _f('fMid', p1: 'mid1', p2: 'mid2'),
      ],
      childLinks: [
        _link('fTop', 'mid1'),
        _link('fTop', 'aunt'), // mid2 的姐妹未建人也无妨，只挂 mid1
        _link('fMid', 'kid2'),
      ],
      textDirection: TextDirection.ltr,
    ));
    expect(_genOf(r, 'top1'), 0);
    expect(_genOf(r, 'top2'), 0);
    expect(_genOf(r, 'mid1'), 1);
    expect(_genOf(r, 'mid2'), 1);
    expect(_genOf(r, 'kid2'), 2);
  });
}
