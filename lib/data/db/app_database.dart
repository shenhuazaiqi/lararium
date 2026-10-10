import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables.dart';

part 'app_database.g.dart';

/// 本地 SQLite 是唯一数据源（规划文档 6.1 核心原则），云只是副本。
@DriftDatabase(
  tables: [Trees, Persons, Families, FamilyChildren, MemorialMessages],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(persons, persons.allowPublicLink);
          }
          if (from < 3) {
            await m.addColumn(persons, persons.avatarPath);
          }
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    await Directory(dir.path).create(recursive: true);
    final file = File(p.join(dir.path, 'lararium.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
