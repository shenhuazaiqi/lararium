import 'package:drift/drift.dart';

import 'db/app_database.dart';
import 'db/tables.dart';

/// 多树管理：创建 / 重命名 / 复制 / 删除（规划 5.2 P0「多树」）。
class TreeService {
  TreeService(this._db);

  final AppDatabase _db;

  Stream<List<Tree>> watchAll() {
    return (_db.select(_db.trees)..where((t) => t.deletedAt.isNull()))
        .watch();
  }

  Future<String> create(String name, {String? description}) async {
    final id = newId();
    await _db.into(_db.trees).insert(TreesCompanion.insert(
          id: Value(id),
          name: name,
          description: Value(description),
        ));
    return id;
  }

  Future<void> rename(String treeId, String name) async {
    await (_db.update(_db.trees)..where((t) => t.id.equals(treeId))).write(
      TreesCompanion(name: Value(name), updatedAt: Value(DateTime.now())),
    );
  }

  /// 复制整棵树（人物/家庭/归属/留言，缅怀计数一并复制）。
  Future<String> duplicate(String treeId, String newName) async {
    final newId_ = await create(newName,
        description: 'Duplicated from an existing tree');
    final persons =
        await (_db.select(_db.persons)..where((p) => p.treeId.equals(treeId)))
            .get();
    final idMap = <String, String>{};
    for (final p in persons) {
      final nid = newId();
      idMap[p.id] = nid;
      await _db.into(_db.persons).insert(PersonsCompanion.insert(
            id: Value(nid),
            treeId: newId_,
            givenName: Value(p.givenName),
            surname: Value(p.surname),
            gender: Value(p.gender),
            birthDate: Value(p.birthDate),
            birthPrecision: Value(p.birthPrecision),
            birthPlace: Value(p.birthPlace),
            deathDate: Value(p.deathDate),
            deathPrecision: Value(p.deathPrecision),
            deathPlace: Value(p.deathPlace),
            burialPlace: Value(p.burialPlace),
            isLiving: Value(p.isLiving),
            occupation: Value(p.occupation),
            note: Value(p.note),
            memorialTheme: Value(p.memorialTheme),
            epitaph: Value(p.epitaph),
            flowerCount: Value(p.flowerCount),
            candleCount: Value(p.candleCount),
            incenseCount: Value(p.incenseCount),
            prayerCount: Value(p.prayerCount),
            messageCount: Value(p.messageCount),
            isSelf: Value(p.isSelf),
          ));
    }
    final families =
        await (_db.select(_db.families)..where((f) => f.treeId.equals(treeId)))
            .get();
    final famMap = <String, String>{};
    for (final f in families) {
      final nid = newId();
      famMap[f.id] = nid;
      await _db.into(_db.families).insert(FamiliesCompanion.insert(
            id: Value(nid),
            treeId: newId_,
            partner1Id: Value(f.partner1Id == null ? null : idMap[f.partner1Id!]),
            partner2Id: Value(f.partner2Id == null ? null : idMap[f.partner2Id!]),
            relationType: Value(f.relationType),
            marriageDate: Value(f.marriageDate),
          ));
    }
    final links = await (_db.select(_db.familyChildren)
          ..where((c) => c.treeId.equals(treeId)))
        .get();
    for (final l in links) {
      await _db.into(_db.familyChildren).insert(FamilyChildrenCompanion.insert(
            familyId: famMap[l.familyId]!,
            treeId: newId_,
            personId: idMap[l.personId]!,
          ));
    }
    final msgs = await (_db.select(_db.memorialMessages)
          ..where((m) => m.treeId.equals(treeId)))
        .get();
    for (final m in msgs) {
      await _db.into(_db.memorialMessages).insert(MemorialMessagesCompanion.insert(
            treeId: newId_,
            personId: idMap[m.personId]!,
            authorName: m.authorName,
            body: m.body,
            likeCount: Value(m.likeCount),
            likedByMe: Value(m.likedByMe),
          ));
    }
    return newId_;
  }

  Future<void> softDelete(String treeId) async {
    await (_db.update(_db.trees)..where((t) => t.id.equals(treeId))).write(
      TreesCompanion(deletedAt: Value(DateTime.now()), updatedAt: Value(DateTime.now())),
    );
  }
}
