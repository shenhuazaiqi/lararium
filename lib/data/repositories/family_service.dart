import 'package:drift/drift.dart';

import '../db/app_database.dart';
import '../db/tables.dart';

enum RelKind { parent, spouse, child, sibling }

/// 家谱结构操作：建人 + 建家庭 + 建归属。
/// 规则对齐规划文档 6.3：families 是配偶单元（可为单亲），children 挂在 family 上。
class FamilyService {
  FamilyService(this._db);

  final AppDatabase _db;

  /// 在 [base] 旁添加一位亲属并建立正确的家庭连接，返回新人 id。
  Future<String> addRelative({
    required String treeId,
    required Person base,
    required RelKind kind,
    required String givenName,
    String surname = '',
    String gender = 'unknown',
    DateTime? birthDate,
    String birthPrecision = 'day',
    String? birthPlace,
    String? occupation,
    bool isLiving = true,
    DateTime? deathDate,
    String deathPrecision = 'day',
    String? burialPlace,
    String? note,
  }) async {
    final newPersonId = newId();
    await _db.into(_db.persons).insert(PersonsCompanion.insert(
          id: Value(newPersonId),
          treeId: treeId,
          givenName: Value(givenName),
          surname: Value(surname.isNotEmpty ? surname : base.surname),
          gender: Value(gender),
          birthDate: Value(birthDate),
          birthPrecision: Value(birthPrecision),
          birthPlace: Value(birthPlace),
          occupation: Value(occupation),
          isLiving: Value(isLiving),
          deathDate: Value(deathDate),
          deathPrecision: Value(deathPrecision),
          burialPlace: Value(burialPlace),
          note: Value(note),
        ));

    switch (kind) {
      case RelKind.parent:
        await _attachParent(treeId, base, newPersonId);
        break;
      case RelKind.spouse:
        await _db.into(_db.families).insert(FamiliesCompanion.insert(
              treeId: treeId,
              partner1Id: Value(base.id),
              partner2Id: Value(newPersonId),
            ));
        break;
      case RelKind.child:
        final familyId = await _familyAsPartner(treeId, base);
        await _db.into(_db.familyChildren).insert(FamilyChildrenCompanion.insert(
              familyId: familyId,
              treeId: treeId,
              personId: newPersonId,
            ));
        break;
      case RelKind.sibling:
        final parentFamilyId = await _familyAsChild(treeId, base);
        String familyId;
        if (parentFamilyId != null) {
          familyId = parentFamilyId;
        } else {
          // base 没有父母家庭：新建（空）家庭，并把 base 也挂进去 → 两人互为兄弟姐妹
          familyId = newId();
          await _db
              .into(_db.families)
              .insert(FamiliesCompanion.insert(id: Value(familyId), treeId: treeId));
          await _db.into(_db.familyChildren).insert(FamilyChildrenCompanion.insert(
                familyId: familyId,
                treeId: treeId,
                personId: base.id,
              ));
        }
        await _db.into(_db.familyChildren).insert(FamilyChildrenCompanion.insert(
              familyId: familyId,
              treeId: treeId,
              personId: newPersonId,
            ));
        break;
    }
    return newPersonId;
  }

  /// 给 [child] 挂一位家长：优先复用其父母的家庭空位，否则新建家庭。
  Future<void> _attachParent(String treeId, Person child, String parentId) async {
    final existing = await _familyAsChild(treeId, child);
    if (existing != null) {
      final fam = await (_db.select(_db.families)
            ..where((f) => f.id.equals(existing)))
          .getSingle();
      if (fam.partner1Id == null) {
        await (_db.update(_db.families)..where((f) => f.id.equals(existing)))
            .write(FamiliesCompanion(partner1Id: Value(parentId)));
        return;
      }
      if (fam.partner2Id == null) {
        await (_db.update(_db.families)..where((f) => f.id.equals(existing)))
            .write(FamiliesCompanion(partner2Id: Value(parentId)));
        return;
      }
      // 父母位已满（如继亲场景）：新建家庭并重复挂孩子（pedegree 默认 birth）
      final fid = newId();
      await _db.into(_db.families).insert(FamiliesCompanion.insert(
          id: Value(fid), treeId: treeId, partner1Id: Value(parentId)));
      await _db.into(_db.familyChildren).insert(FamilyChildrenCompanion.insert(
            familyId: fid,
            treeId: treeId,
            personId: child.id,
          ));
      return;
    }
    final fid = newId();
    await _db.into(_db.families).insert(FamiliesCompanion.insert(
        id: Value(fid), treeId: treeId, partner1Id: Value(parentId)));
    await _db.into(_db.familyChildren).insert(FamilyChildrenCompanion.insert(
          familyId: fid,
          treeId: treeId,
          personId: child.id,
        ));
  }

  /// 该人作为「孩子」所属的第一个家庭 id。
  Future<String?> _familyAsChild(String treeId, Person person) async {
    final rows = await (_db.select(_db.familyChildren)
          ..where((fc) => fc.personId.equals(person.id)))
        .get();
    if (rows.isEmpty) return null;
    return rows.first.familyId;
  }

  /// 该人作为「伴侣」参与的第一个家庭 id，没有则新建（partner1 = 本人）。
  Future<String> _familyAsPartner(String treeId, Person person) async {
    final rows = await (_db.select(_db.families)
          ..where((f) =>
              f.treeId.equals(treeId) &
              f.deletedAt.isNull() &
              (f.partner1Id.equals(person.id) | f.partner2Id.equals(person.id))))
        .get();
    if (rows.isNotEmpty) return rows.first.id;
    final fid = newId();
    await _db.into(_db.families).insert(FamiliesCompanion.insert(
        id: Value(fid), treeId: treeId, partner1Id: Value(person.id)));
    return fid;
  }
}
