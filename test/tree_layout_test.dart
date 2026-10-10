// 树布局引擎回归测试 —— 重点覆盖「父母代必须显示在子女代上方」。
// 回归背景：旧根选择按人物列表顺序取"未被收编者"，本人先入列时
// 其父母会被平铺成同代独立根（2026-10-10 用户报告）。
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
