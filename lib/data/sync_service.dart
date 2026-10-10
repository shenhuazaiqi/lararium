import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'db/app_database.dart';

enum SyncPhase { idle, pushing, pulling, done, error }

class SyncStatus {
  const SyncStatus({
    this.phase = SyncPhase.idle,
    this.pushed = 0,
    this.pulled = 0,
    this.lastSyncAt,
    this.error,
  });

  final SyncPhase phase;
  final int pushed;
  final int pulled;
  final DateTime? lastSyncAt;
  final String? error;

  SyncStatus copyWith({
    SyncPhase? phase,
    int? pushed,
    int? pulled,
    DateTime? lastSyncAt,
    String? error,
  }) =>
      SyncStatus(
        phase: phase ?? this.phase,
        pushed: pushed ?? this.pushed,
        pulled: pulled ?? this.pulled,
        lastSyncAt: lastSyncAt ?? this.lastSyncAt,
        error: error,
      );
}

/// 云同步（阶段 3 骨架，规划 6.4 的简化落地）：
/// - 登录后整树推送（upsert by id）+ 拉取合并（LWW by updated_at）。
/// - 本地 SQLite 仍是唯一真源；云只是副本。断网时一切照常。
/// - outbox 增量队列（6.4 完整版）在后续里程碑替换 pushAll/pullAll。
class SyncService {
  SyncService(this._db);

  final AppDatabase _db;
  SupabaseClient get _client => Supabase.instance.client;

  bool get isSignedIn => _client.auth.currentSession != null;
  String? get currentEmail => _client.auth.currentUser?.email;
  String? get currentUserId => _client.auth.currentUser?.id;

  Future<void> signIn(String email, String password) =>
      _client.auth.signInWithPassword(email: email, password: password);

  Future<void> signUp(String email, String password) =>
      _client.auth.signUp(email: email, password: password);

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// 把一棵本地树推到云端 + 拉回远端更新（LWW）。
  Future<SyncStatus> syncTree(String treeId, {DateTime? lastSyncAt}) async {
    if (!isSignedIn) {
      return const SyncStatus(phase: SyncPhase.error, error: 'not-signed-in');
    }
    final uid = currentUserId!;
    var pushed = 0;
    var pulled = 0;

    // 1) 确保云端存在这棵树且本人是 owner
    final tree = await (_db.select(_db.trees)..where((t) => t.id.equals(treeId)))
        .getSingleOrNull();
    if (tree != null) {
      await _client.from('trees').upsert({
        'id': tree.id,
        'name': tree.name,
        'description': tree.description,
        'owner_id': uid,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
      // 先查后插：upsert 的 RETURNING 会撞 RLS 快照可见性（函数读不到未提交行）
      final existingMember = await _client
          .from('tree_members')
          .select('user_id')
          .eq('tree_id', tree.id)
          .eq('user_id', uid);
      if (((existingMember as List?) ?? []).isEmpty) {
        await _client.from('tree_members').insert({
          'tree_id': tree.id,
          'user_id': uid,
          'role': 'owner',
        });
      }
    }

    // 2) 推送 persons（upsert by id）
    final persons = await (_db.select(_db.persons)
          ..where((p) => p.treeId.equals(treeId) & p.deletedAt.isNull()))
        .get();
    if (persons.isNotEmpty) {
      await _client.from('persons').upsert([
        for (final p in persons)
          {
            'id': p.id,
            'tree_id': treeId,
            'given_name': p.givenName,
            'surname': p.surname,
            'gender': p.gender,
            'birth_date': p.birthDate?.toIso8601String().substring(0, 10),
            'birth_date_precision': p.birthPrecision,
            'birth_place': p.birthPlace,
            'death_date': p.deathDate?.toIso8601String().substring(0, 10),
            'death_date_precision': p.deathPrecision,
            'death_place': p.deathPlace,
            'burial_place': p.burialPlace,
            'is_living': p.isLiving,
            'occupation': p.occupation,
            'note': p.note,
            'is_self': p.isSelf,
            'client_updated_at': p.updatedAt.toUtc().toIso8601String(),
            'created_by': uid,
          }
      ]);
      pushed += persons.length;
    }

    // 3) 推送 families / family_children / memorial_messages
    final families = await (_db.select(_db.families)
          ..where((f) => f.treeId.equals(treeId) & f.deletedAt.isNull()))
        .get();
    if (families.isNotEmpty) {
      await _client.from('families').upsert([
        for (final f in families)
          {
            'id': f.id,
            'tree_id': treeId,
            'partner1_id': f.partner1Id,
            'partner2_id': f.partner2Id,
            'relation_type': f.relationType,
            'marriage_date': f.marriageDate?.toIso8601String().substring(0, 10),
          }
      ]);
      pushed += families.length;
    }
    final links = await (_db.select(_db.familyChildren)
          ..where((c) => c.treeId.equals(treeId)))
        .get();
    if (links.isNotEmpty) {
      await _client.from('family_children').upsert([
        for (final l in links)
          {
            'family_id': l.familyId,
            'tree_id': treeId,
            'person_id': l.personId,
            'sort_order': l.sortOrder,
            'pedigree': l.pedigree,
          }
      ]);
      pushed += links.length;
    }

    // ---------- 推送：memorial_profiles（主题/计数/公开开关） ----------
    final profiles = await (_db.select(_db.persons)
          ..where((p) => p.treeId.equals(treeId) & p.deletedAt.isNull()))
        .get();
    await _client.from('memorial_profiles').upsert([
      for (final p in profiles)
        {
          'person_id': p.id,
          'tree_id': treeId,
          'theme': p.memorialTheme,
          'epitaph': p.epitaph,
          'flower_count': p.flowerCount,
          'candle_count': p.candleCount,
          'incense_count': p.incenseCount,
          'prayer_count': p.prayerCount,
          'message_count': p.messageCount,
          'allow_public_link': p.allowPublicLink,
          'last_memorial_at': p.lastMemorialAt?.toUtc().toIso8601String(),
        }
    ]);
    pushed += profiles.length;
    final msgs = await (_db.select(_db.memorialMessages)
          ..where((m) => m.treeId.equals(treeId)))
        .get();
    if (msgs.isNotEmpty) {
      try {
        await _client.from('memorial_messages').upsert([
          for (final m in msgs)
            {
              'id': m.id,
              'tree_id': treeId,
              'person_id': m.personId,
              'author_name': m.authorName,
              'body': m.body,
            }
        ]);
        pushed += msgs.length;
      } catch (_) {
        // 留言受 RLS author_user_id 约束，本地未登录历史留言跳过
      }
    }

    // 4) 拉取远端 persons（LWW 合并）
    final remote = await _client
        .from('persons')
        .select()
        .eq('tree_id', treeId) as List<dynamic>;
    for (final row in remote) {
      final map = row as Map<String, dynamic>;
      final id = map['id'] as String;
      final remoteUpdatedAt =
          DateTime.tryParse('${map['client_updated_at'] ?? ''}') ??
              DateTime.fromMillisecondsSinceEpoch(0);
      final local =
          await (_db.select(_db.persons)..where((p) => p.id.equals(id)))
              .getSingleOrNull();
      final remoteIsDeleted = map['deleted_at'] != null;
      if (remoteIsDeleted) continue;
      if (local == null) {
        await _db.into(_db.persons).insert(PersonsCompanion.insert(
              id: Value(id),
              treeId: treeId,
              givenName: Value('${map['given_name'] ?? ''}'),
              surname: Value('${map['surname'] ?? ''}'),
              gender: Value('${map['gender'] ?? 'unknown'}'),
              birthDate: Value(_parseDate(map['birth_date'])),
              birthPlace: Value(map['birth_place'] as String?),
              deathDate: Value(_parseDate(map['death_date'])),
              deathPlace: Value(map['death_place'] as String?),
              isLiving: Value(map['is_living'] as bool? ?? true),
              occupation: Value(map['occupation'] as String?),
              note: Value(map['note'] as String?),
              isSelf: Value(map['is_self'] as bool? ?? false),
            ));
        pulled++;
      } else if (remoteUpdatedAt.isAfter(local.updatedAt)) {
        await (_db.update(_db.persons)..where((p) => p.id.equals(id))).write(
          PersonsCompanion(
            givenName: Value('${map['given_name'] ?? local.givenName}'),
            surname: Value('${map['surname'] ?? local.surname}'),
            occupation: Value(map['occupation'] as String? ?? local.occupation),
            updatedAt: Value(DateTime.now()),
          ),
        );
        pulled++;
      }
    }

    // ---------- 拉取：families ----------
    final remoteFams = await _client
        .from('families')
        .select()
        .eq('tree_id', treeId) as List<dynamic>;
    for (final row in remoteFams) {
      final map = row as Map<String, dynamic>;
      final id = map['id'] as String;
      final local = await (_db.select(_db.families)
            ..where((f) => f.id.equals(id)))
          .getSingleOrNull();
      if (local == null) {
        await _db.into(_db.families).insert(FamiliesCompanion.insert(
              id: Value(id),
              treeId: treeId,
              partner1Id: Value(map['partner1_id'] as String?),
              partner2Id: Value(map['partner2_id'] as String?),
              relationType: Value('${map['relation_type'] ?? 'married'}'),
              marriageDate: Value(_parseDate(map['marriage_date'])),
            ));
        pulled++;
      }
    }

    // ---------- 拉取：family_children ----------
    final remoteLinks = await _client
        .from('family_children')
        .select()
        .eq('tree_id', treeId) as List<dynamic>;
    final existingLinks = await (_db.select(_db.familyChildren)
          ..where((c) => c.treeId.equals(treeId)))
        .get();
    final linkKeys = existingLinks.map((l) => '${l.familyId}|${l.personId}').toSet();
    for (final row in remoteLinks) {
      final map = row as Map<String, dynamic>;
      final key = "${map['family_id']}|${map['person_id']}";
      if (!linkKeys.contains(key)) {
        await _db.into(_db.familyChildren).insert(FamilyChildrenCompanion.insert(
              familyId: map['family_id'] as String,
              treeId: treeId,
              personId: map['person_id'] as String,
            ));
        pulled++;
      }
    }

    // ---------- 拉取：memorial_messages（按 id 缺失即插入） ----------
    final remoteMsgs = await _client
        .from('memorial_messages')
        .select()
        .eq('tree_id', treeId) as List<dynamic>;
    final localMsgRows = await (_db.select(_db.memorialMessages)
          ..where((m) => m.treeId.equals(treeId)))
        .get();
    final localMsgIds = localMsgRows.map((m) => m.id).toSet();
    for (final row in remoteMsgs) {
      final map = row as Map<String, dynamic>;
      final id = map['id'] as String;
      if (localMsgIds.contains(id)) continue;
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

    // ---------- 拉取：memorial_profiles（主题/计数/公开开关 → 本地 persons） ----------
    final remoteProfiles = await _client
        .from('memorial_profiles')
        .select()
        .eq('tree_id', treeId) as List<dynamic>;
    for (final row in remoteProfiles) {
      final map = row as Map<String, dynamic>;
      final pid = map['person_id'] as String;
      final local = await (_db.select(_db.persons)
            ..where((p) => p.id.equals(pid)))
          .getSingleOrNull();
      if (local == null) continue;
      await (_db.update(_db.persons)..where((p) => p.id.equals(pid))).write(
        PersonsCompanion(
          memorialTheme: Value(map['theme'] as String? ?? local.memorialTheme),
          epitaph: Value(map['epitaph'] as String? ?? local.epitaph),
          flowerCount: Value(map['flower_count'] as int? ?? local.flowerCount),
          candleCount: Value(map['candle_count'] as int? ?? local.candleCount),
          incenseCount:
              Value(map['incense_count'] as int? ?? local.incenseCount),
          prayerCount: Value(map['prayer_count'] as int? ?? local.prayerCount),
          messageCount:
              Value(map['message_count'] as int? ?? local.messageCount),
          allowPublicLink:
              Value(map['allow_public_link'] as bool? ?? local.allowPublicLink),
        ),
      );
    }

    final now = DateTime.now();
    return SyncStatus(
      phase: SyncPhase.done,
      pushed: pushed,
      pulled: pulled,
      lastSyncAt: now,
    );
  }

  DateTime? _parseDate(dynamic s) {
    if (s == null) return null;
    return DateTime.tryParse('$s');
  }
}
