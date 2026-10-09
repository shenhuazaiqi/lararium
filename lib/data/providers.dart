import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Family;
import 'package:shared_preferences/shared_preferences.dart';

import 'db/app_database.dart';
import 'db/tables.dart';
import 'repositories/demo_seed.dart';
import 'repositories/family_service.dart';

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
