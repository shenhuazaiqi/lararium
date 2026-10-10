import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

/// 数据模型：与规划文档 6.3 章的schema 对齐（本地 SQLite 版）。
/// 命名遵循 drift 约定：Dart camelCase → SQL snake_case。

@DataClassName('Tree')
class Trees extends Table {
  TextColumn get id => text().clientDefault(newId)();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  BoolColumn get isDemo => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Person')
class Persons extends Table {
  TextColumn get id => text().clientDefault(newId)();
  TextColumn get treeId => text()();
  TextColumn get givenName => text().withDefault(const Constant(''))();
  TextColumn get surname => text().withDefault(const Constant(''))();
  // male | female | other | unknown
  TextColumn get gender => text().withDefault(const Constant('unknown'))();

  DateTimeColumn get birthDate => dateTime().nullable()();
  // day | month | year | approx —— 模糊日期（"约 1900"）在 GEDCOM 阶段启用
  TextColumn get birthPrecision => text().withDefault(const Constant('day'))();
  TextColumn get birthPlace => text().nullable()();

  DateTimeColumn get deathDate => dateTime().nullable()();
  TextColumn get deathPrecision => text().withDefault(const Constant('day'))();
  TextColumn get deathPlace => text().nullable()();
  TextColumn get burialPlace => text().nullable()();

  // 在世人隐私脱敏（文档 5.4.5：在世者强制隐藏缅怀入口）
  BoolColumn get isLiving => boolean().withDefault(const Constant(true))();

  TextColumn get occupation => text().nullable()();
  TextColumn get note => text().nullable()();

  // --- 缅怀（人物级，云同步阶段映射到 memorial_profiles） ---
  // western | east_asian | latin | jewish | hindu | islamic | secular
  // 公开纪念页开关（5.4.2：默认关闭，用户显式开启后分享链接）
  BoolColumn get allowPublicLink =>
      boolean().withDefault(const Constant(false))();
  TextColumn get memorialTheme => text().nullable()();
  TextColumn get epitaph => text().nullable()();
  IntColumn get flowerCount => integer().withDefault(const Constant(0))();
  IntColumn get candleCount => integer().withDefault(const Constant(0))();
  IntColumn get incenseCount => integer().withDefault(const Constant(0))();
  IntColumn get prayerCount => integer().withDefault(const Constant(0))();
  IntColumn get messageCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastMemorialAt => dateTime().nullable()();

  /// 树的「焦点人物」（如"我"），默认视图居中。
  BoolColumn get isSelf => boolean().withDefault(const Constant(false))();

  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 核心家庭单元（GEDCOM 的 FAM）：配偶/伴侣，可单亲。
@DataClassName('Family')
class Families extends Table {
  TextColumn get id => text().clientDefault(newId)();
  TextColumn get treeId => text()();
  TextColumn get partner1Id => text().nullable()();
  TextColumn get partner2Id => text().nullable()();
  // married | unmarried | divorced | partner
  TextColumn get relationType =>
      text().withDefault(const Constant('married'))();
  DateTimeColumn get marriageDate => dateTime().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 子女归属：一个孩子可属于多个家庭（亲生 + 收养）。
@DataClassName('FamilyChildLink')
class FamilyChildren extends Table {
  TextColumn get familyId => text()();
  TextColumn get treeId => text()();
  TextColumn get personId => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  // birth | adopted | foster | step
  TextColumn get pedigree => text().withDefault(const Constant('birth'))();

  @override
  Set<Column> get primaryKey => {familyId, personId};
}

/// 纪念留言（本地先行；云阶段映射 memorial_messages，加 UGC 合规字段）。
@DataClassName('MemorialMessage')
class MemorialMessages extends Table {
  TextColumn get id => text().clientDefault(newId)();
  TextColumn get treeId => text()();
  TextColumn get personId => text()();
  TextColumn get authorName => text()();
  BoolColumn get isAnonymous => boolean().withDefault(const Constant(false))();
  TextColumn get body => text()();
  IntColumn get likeCount => integer().withDefault(const Constant(0))();
  BoolColumn get likedByMe => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

const _uuid = Uuid();

String newId() => _uuid.v4();
