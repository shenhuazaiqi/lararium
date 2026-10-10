import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'db/app_database.dart';
import 'db/tables.dart';

/// 协作邀请 + 成员（阶段 3 邀请协作的落地）。
class InviteService {
  InviteService(this._db);

  final AppDatabase _db;
  SupabaseClient get _client => Supabase.instance.client;

  /// 树所有者生成 8 位邀请码。
  Future<String> createInvite(String treeId, {String role = 'editor'}) async {
    final code = await _client
        .rpc('create_invite', params: {'tid': treeId, 'role': role});
    return '$code';
  }

  /// 兑换邀请码：云端加入树成员 → 把云端整树拉取到本地（同 tree_id）。
  /// 返回 (treeId, treeName)。
  Future<(String, String)> redeem(String code) async {
    final result = await _client.rpc('redeem_invite', params: {'code': code});
    final map = Map<String, dynamic>.from(result as Map);
    final treeId = map['tree_id'] as String;
    final treeName = '${map['name'] ?? 'Shared tree'}';

    // 本地若没有这棵树的行（跨设备），创建同名本地行（id 与云端一致）
    final local = await (_db.select(_db.trees)..where((t) => t.id.equals(treeId)))
        .getSingleOrNull();
    if (local == null) {
      await (_db.into(_db.trees)).insert(TreesCompanion.insert(
            id: Value(treeId),
            name: treeName,
            description: const Value('Shared with you'),
          ));
      // drift insert 返回行数而非 id；treeId 已知，无需回读
    }

    // 拉取人物/家庭/归属/留言/缅怀字段到本地（按 id 幂等）
    var pulled = 0;
    final remotePersons = await _client
        .from('persons')
        .select()
        .eq('tree_id', treeId) as List<dynamic>;
    for (final row in remotePersons) {
      final map = row as Map<String, dynamic>;
      final id = map['id'] as String;
      final exists = await (_db.select(_db.persons)..where((p) => p.id.equals(id)))
          .getSingleOrNull();
      if (exists != null || (map['deleted_at'] != null)) continue;
      await _db.into(_db.persons).insert(PersonsCompanion.insert(
            id: Value(id),
            treeId: treeId,
            givenName: Value('${map['given_name'] ?? ''}'),
            surname: Value('${map['surname'] ?? ''}'),
            gender: Value('${map['gender'] ?? 'unknown'}'),
            birthDate: Value(_date(map['birth_date'])),
            birthPrecision: Value('${map['birth_precision'] ?? 'day'}'),
            birthPlace: Value(map['birth_place'] as String?),
            deathDate: Value(_date(map['death_date'])),
            deathPrecision: Value('${map['death_precision'] ?? 'day'}'),
            deathPlace: Value(map['death_place'] as String?),
            burialPlace: Value(map['burial_place'] as String?),
            isLiving: Value(map['is_living'] as bool? ?? true),
            occupation: Value(map['occupation'] as String?),
            note: Value(map['note'] as String?),
            isSelf: Value(map['is_self'] as bool? ?? false),
          ));
      pulled++;
    }
    final remoteFams = await _client
        .from('families')
        .select()
        .eq('tree_id', treeId) as List<dynamic>;
    for (final row in remoteFams) {
      final map = row as Map<String, dynamic>;
      final id = map['id'] as String;
      final exists = await (_db.select(_db.families)..where((f) => f.id.equals(id)))
          .getSingleOrNull();
      if (exists != null) continue;
      await _db.into(_db.families).insert(FamiliesCompanion.insert(
            id: Value(id),
            treeId: treeId,
            partner1Id: Value(map['partner1_id'] as String?),
            partner2Id: Value(map['partner2_id'] as String?),
            relationType: Value('${map['relation_type'] ?? 'married'}'),
            marriageDate: Value(_date(map['marriage_date'])),
          ));
      pulled++;
    }
    final remoteLinks = await _client
        .from('family_children')
        .select()
        .eq('tree_id', treeId) as List<dynamic>;
    final localLinks = await (_db.select(_db.familyChildren)
          ..where((c) => c.treeId.equals(treeId)))
        .get();
    final linkKeys =
        localLinks.map((l) => '${l.familyId}|${l.personId}').toSet();
    for (final row in remoteLinks) {
      final map = row as Map<String, dynamic>;
      final key = '${map['family_id']}|${map['person_id']}';
      if (linkKeys.contains(key)) continue;
      await _db.into(_db.familyChildren).insert(FamilyChildrenCompanion.insert(
            familyId: map['family_id'] as String,
            treeId: treeId,
            personId: map['person_id'] as String,
          ));
      pulled++;
    }
    final remoteMsgs = await _client
        .from('memorial_messages')
        .select()
        .eq('tree_id', treeId) as List<dynamic>;
    final localMsgs = await (_db.select(_db.memorialMessages)
          ..where((m) => m.treeId.equals(treeId)))
        .get();
    final msgIds = localMsgs.map((m) => m.id).toSet();
    for (final row in remoteMsgs) {
      final map = row as Map<String, dynamic>;
      final id = map['id'] as String;
      if (msgIds.contains(id)) continue;
      if ((map['status'] ?? 'visible') != 'visible') continue;
      await _db.into(_db.memorialMessages).insert(MemorialMessagesCompanion.insert(
            id: Value(id),
            treeId: treeId,
            personId: map['person_id'] as String,
            authorName: '${map['author_name'] ?? ''}',
            body: '${map['body'] ?? ''}',
          ));
      pulled++;
    }

    return (treeId, treeName);
  }

  /// 当前树的成员列表（user_id + 角色）。
  Future<List<({String userId, String role})>> members(String treeId) async {
    final rows = await _client
        .from('tree_members')
        .select('user_id, role')
        .eq('tree_id', treeId) as List<dynamic>;
    return rows
        .map((r) => (
              userId: '${(r as Map)['user_id']}',
              role: '${(r as Map)['role']}',
            ))
        .toList();
  }

  DateTime? _date(dynamic s) => s == null ? null : DateTime.tryParse('$s');
}
