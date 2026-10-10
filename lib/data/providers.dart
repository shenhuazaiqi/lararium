import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Family;
import 'package:shared_preferences/shared_preferences.dart';

import 'db/app_database.dart';
import 'db/tables.dart';
import 'repositories/demo_seed.dart';
import 'repositories/family_service.dart';
import 'sync_service.dart';
import 'tree_service.dart';

/// SharedPreferences 在 main() 里 override 注入。
final prefsProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('override in main'),
);

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final familyServiceProvider =
    Provider<FamilyService>((ref) => FamilyService(ref.watch(databaseProvider)));

final treeServiceProvider =
    Provider<TreeService>((ref) => TreeService(ref.watch(databaseProvider)));

final syncServiceProvider =
    Provider<SyncService>((ref) => SyncService(ref.watch(databaseProvider)));

/// 同步状态流（同步屏与设置页共用）
final syncStatusProvider = StateProvider<SyncStatus>((ref) => const SyncStatus());

/// 当前登录邮箱（null = 未登录）
final authEmailProvider = StateProvider<String?>((ref) => null);

final treesListProvider = StreamProvider<List<Tree>>((ref) {
  return ref.watch(treeServiceProvider).watchAll();
});

/// 当前树的名字（多树切换后标题跟随）
final currentTreeNameProvider = Provider<String?>((ref) {
  final id = ref.watch(effectiveTreeIdProvider);
  if (id == null) return null;
  final trees = ref.watch(treesListProvider).value ?? const <Tree>[];
  for (final t in trees) {
    if (t.id == id) return t.name;
  }
  return null;
});

/// 当前选中的树（多树管理）。null = 未选择 → 回落到默认树。
final currentTreeIdProvider = StateProvider<String?>((ref) => null);

/// 各屏统一使用：显式选择优先，否则默认树。
final effectiveTreeIdProvider = Provider<String?>((ref) {
  return ref.watch(currentTreeIdProvider) ??
      ref.watch(defaultTreeProvider).value?.id;
});

/// 确保存在默认树（空库时播种示例家谱），返回其 id。
final defaultTreeProvider = FutureProvider<Tree>((ref) async {
  final db = ref.watch(databaseProvider);
  final existing = await (db.select(db.trees)
        ..where((t) => t.deletedAt.isNull()))
      .get();
  if (existing.isNotEmpty) return existing.first;
  final seed = DemoSeed(db);
  final treeId = await seed.seed();
  return (db.select(db.trees)..where((t) => t.id.equals(treeId))).getSingle();
});

final personsProvider =
    StreamProvider.family<List<Person>, String>((ref, treeId) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.persons)
        ..where((p) => p.treeId.equals(treeId) & p.deletedAt.isNull())
        ..orderBy([(p) => OrderingTerm.asc(p.createdAt)]))
      .watch();
});

final familiesProvider =
    StreamProvider.family<List<Family>, String>((ref, treeId) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.families)
        ..where((f) => f.treeId.equals(treeId) & f.deletedAt.isNull()))
      .watch();
});

final childLinksProvider =
    StreamProvider.family<List<FamilyChildLink>, String>((ref, treeId) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.familyChildren)
        ..where((fc) => fc.treeId.equals(treeId)))
      .watch();
});

final messagesProvider =
    StreamProvider.family<List<MemorialMessage>, String>((ref, personId) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.memorialMessages)
        ..where((m) => m.personId.equals(personId))
        ..orderBy([(m) => OrderingTerm.desc(m.createdAt)]))
      .watch();
});

final personProvider = StreamProvider.family<Person?, String>((ref, id) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.persons)..where((p) => p.id.equals(id)))
      .watchSingleOrNull();
});

/// 深浅色模式（持久化）。null = 跟随系统。
final themeModeProvider =
    StateProvider<ThemeModePrefs>((ref) => ThemeModePrefs.system);

class ThemeModePrefs {
  const ThemeModePrefs._(this.value);
  final String value; // system | light | dark
  static const system = ThemeModePrefs._('system');
  static const light = ThemeModePrefs._('light');
  static const dark = ThemeModePrefs._('dark');
  bool get isDark => value == 'dark';
  bool get followsSystem => value == 'system';
}

/// 语言覆盖（持久化）。null = 跟随系统自动匹配。
final localeOverrideProvider = StateProvider<String?>((ref) => null);

/// 缅怀默认主题包（全局兜底，人物级选择优先）。
final memorialDefaultThemeProvider = StateProvider<String?>((ref) => null);
