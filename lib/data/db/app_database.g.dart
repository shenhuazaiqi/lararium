// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $TreesTable extends Trees with TableInfo<$TreesTable, Tree> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TreesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      clientDefault: newId);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isDemoMeta = const VerificationMeta('isDemo');
  @override
  late final GeneratedColumn<bool> isDemo = GeneratedColumn<bool>(
      'is_demo', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_demo" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, description, isDemo, createdAt, updatedAt, deletedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trees';
  @override
  VerificationContext validateIntegrity(Insertable<Tree> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('is_demo')) {
      context.handle(_isDemoMeta,
          isDemo.isAcceptableOrUnknown(data['is_demo']!, _isDemoMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Tree map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tree(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      isDemo: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_demo'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $TreesTable createAlias(String alias) {
    return $TreesTable(attachedDatabase, alias);
  }
}

class Tree extends DataClass implements Insertable<Tree> {
  final String id;
  final String name;
  final String? description;
  final bool isDemo;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const Tree(
      {required this.id,
      required this.name,
      this.description,
      required this.isDemo,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['is_demo'] = Variable<bool>(isDemo);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  TreesCompanion toCompanion(bool nullToAbsent) {
    return TreesCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      isDemo: Value(isDemo),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Tree.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tree(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      isDemo: serializer.fromJson<bool>(json['isDemo']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'isDemo': serializer.toJson<bool>(isDemo),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  Tree copyWith(
          {String? id,
          String? name,
          Value<String?> description = const Value.absent(),
          bool? isDemo,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent()}) =>
      Tree(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description.present ? description.value : this.description,
        isDemo: isDemo ?? this.isDemo,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
      );
  Tree copyWithCompanion(TreesCompanion data) {
    return Tree(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      isDemo: data.isDemo.present ? data.isDemo.value : this.isDemo,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tree(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('isDemo: $isDemo, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, name, description, isDemo, createdAt, updatedAt, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tree &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.isDemo == this.isDemo &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class TreesCompanion extends UpdateCompanion<Tree> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<bool> isDemo;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const TreesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.isDemo = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TreesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.description = const Value.absent(),
    this.isDemo = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Tree> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<bool>? isDemo,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (isDemo != null) 'is_demo': isDemo,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TreesCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? description,
      Value<bool>? isDemo,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<int>? rowid}) {
    return TreesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isDemo: isDemo ?? this.isDemo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (isDemo.present) {
      map['is_demo'] = Variable<bool>(isDemo.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TreesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('isDemo: $isDemo, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PersonsTable extends Persons with TableInfo<$PersonsTable, Person> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PersonsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      clientDefault: newId);
  static const VerificationMeta _treeIdMeta = const VerificationMeta('treeId');
  @override
  late final GeneratedColumn<String> treeId = GeneratedColumn<String>(
      'tree_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _givenNameMeta =
      const VerificationMeta('givenName');
  @override
  late final GeneratedColumn<String> givenName = GeneratedColumn<String>(
      'given_name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _surnameMeta =
      const VerificationMeta('surname');
  @override
  late final GeneratedColumn<String> surname = GeneratedColumn<String>(
      'surname', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _genderMeta = const VerificationMeta('gender');
  @override
  late final GeneratedColumn<String> gender = GeneratedColumn<String>(
      'gender', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('unknown'));
  static const VerificationMeta _birthDateMeta =
      const VerificationMeta('birthDate');
  @override
  late final GeneratedColumn<DateTime> birthDate = GeneratedColumn<DateTime>(
      'birth_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _birthPrecisionMeta =
      const VerificationMeta('birthPrecision');
  @override
  late final GeneratedColumn<String> birthPrecision = GeneratedColumn<String>(
      'birth_precision', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('day'));
  static const VerificationMeta _birthPlaceMeta =
      const VerificationMeta('birthPlace');
  @override
  late final GeneratedColumn<String> birthPlace = GeneratedColumn<String>(
      'birth_place', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _deathDateMeta =
      const VerificationMeta('deathDate');
  @override
  late final GeneratedColumn<DateTime> deathDate = GeneratedColumn<DateTime>(
      'death_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _deathPrecisionMeta =
      const VerificationMeta('deathPrecision');
  @override
  late final GeneratedColumn<String> deathPrecision = GeneratedColumn<String>(
      'death_precision', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('day'));
  static const VerificationMeta _deathPlaceMeta =
      const VerificationMeta('deathPlace');
  @override
  late final GeneratedColumn<String> deathPlace = GeneratedColumn<String>(
      'death_place', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _burialPlaceMeta =
      const VerificationMeta('burialPlace');
  @override
  late final GeneratedColumn<String> burialPlace = GeneratedColumn<String>(
      'burial_place', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isLivingMeta =
      const VerificationMeta('isLiving');
  @override
  late final GeneratedColumn<bool> isLiving = GeneratedColumn<bool>(
      'is_living', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_living" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _occupationMeta =
      const VerificationMeta('occupation');
  @override
  late final GeneratedColumn<String> occupation = GeneratedColumn<String>(
      'occupation', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _allowPublicLinkMeta =
      const VerificationMeta('allowPublicLink');
  @override
  late final GeneratedColumn<bool> allowPublicLink = GeneratedColumn<bool>(
      'allow_public_link', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("allow_public_link" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _memorialThemeMeta =
      const VerificationMeta('memorialTheme');
  @override
  late final GeneratedColumn<String> memorialTheme = GeneratedColumn<String>(
      'memorial_theme', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _epitaphMeta =
      const VerificationMeta('epitaph');
  @override
  late final GeneratedColumn<String> epitaph = GeneratedColumn<String>(
      'epitaph', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _flowerCountMeta =
      const VerificationMeta('flowerCount');
  @override
  late final GeneratedColumn<int> flowerCount = GeneratedColumn<int>(
      'flower_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _candleCountMeta =
      const VerificationMeta('candleCount');
  @override
  late final GeneratedColumn<int> candleCount = GeneratedColumn<int>(
      'candle_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _incenseCountMeta =
      const VerificationMeta('incenseCount');
  @override
  late final GeneratedColumn<int> incenseCount = GeneratedColumn<int>(
      'incense_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _prayerCountMeta =
      const VerificationMeta('prayerCount');
  @override
  late final GeneratedColumn<int> prayerCount = GeneratedColumn<int>(
      'prayer_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _messageCountMeta =
      const VerificationMeta('messageCount');
  @override
  late final GeneratedColumn<int> messageCount = GeneratedColumn<int>(
      'message_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lastMemorialAtMeta =
      const VerificationMeta('lastMemorialAt');
  @override
  late final GeneratedColumn<DateTime> lastMemorialAt =
      GeneratedColumn<DateTime>('last_memorial_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _isSelfMeta = const VerificationMeta('isSelf');
  @override
  late final GeneratedColumn<bool> isSelf = GeneratedColumn<bool>(
      'is_self', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_self" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        treeId,
        givenName,
        surname,
        gender,
        birthDate,
        birthPrecision,
        birthPlace,
        deathDate,
        deathPrecision,
        deathPlace,
        burialPlace,
        isLiving,
        occupation,
        note,
        allowPublicLink,
        memorialTheme,
        epitaph,
        flowerCount,
        candleCount,
        incenseCount,
        prayerCount,
        messageCount,
        lastMemorialAt,
        isSelf,
        createdAt,
        updatedAt,
        deletedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'persons';
  @override
  VerificationContext validateIntegrity(Insertable<Person> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('tree_id')) {
      context.handle(_treeIdMeta,
          treeId.isAcceptableOrUnknown(data['tree_id']!, _treeIdMeta));
    } else if (isInserting) {
      context.missing(_treeIdMeta);
    }
    if (data.containsKey('given_name')) {
      context.handle(_givenNameMeta,
          givenName.isAcceptableOrUnknown(data['given_name']!, _givenNameMeta));
    }
    if (data.containsKey('surname')) {
      context.handle(_surnameMeta,
          surname.isAcceptableOrUnknown(data['surname']!, _surnameMeta));
    }
    if (data.containsKey('gender')) {
      context.handle(_genderMeta,
          gender.isAcceptableOrUnknown(data['gender']!, _genderMeta));
    }
    if (data.containsKey('birth_date')) {
      context.handle(_birthDateMeta,
          birthDate.isAcceptableOrUnknown(data['birth_date']!, _birthDateMeta));
    }
    if (data.containsKey('birth_precision')) {
      context.handle(
          _birthPrecisionMeta,
          birthPrecision.isAcceptableOrUnknown(
              data['birth_precision']!, _birthPrecisionMeta));
    }
    if (data.containsKey('birth_place')) {
      context.handle(
          _birthPlaceMeta,
          birthPlace.isAcceptableOrUnknown(
              data['birth_place']!, _birthPlaceMeta));
    }
    if (data.containsKey('death_date')) {
      context.handle(_deathDateMeta,
          deathDate.isAcceptableOrUnknown(data['death_date']!, _deathDateMeta));
    }
    if (data.containsKey('death_precision')) {
      context.handle(
          _deathPrecisionMeta,
          deathPrecision.isAcceptableOrUnknown(
              data['death_precision']!, _deathPrecisionMeta));
    }
    if (data.containsKey('death_place')) {
      context.handle(
          _deathPlaceMeta,
          deathPlace.isAcceptableOrUnknown(
              data['death_place']!, _deathPlaceMeta));
    }
    if (data.containsKey('burial_place')) {
      context.handle(
          _burialPlaceMeta,
          burialPlace.isAcceptableOrUnknown(
              data['burial_place']!, _burialPlaceMeta));
    }
    if (data.containsKey('is_living')) {
      context.handle(_isLivingMeta,
          isLiving.isAcceptableOrUnknown(data['is_living']!, _isLivingMeta));
    }
    if (data.containsKey('occupation')) {
      context.handle(
          _occupationMeta,
          occupation.isAcceptableOrUnknown(
              data['occupation']!, _occupationMeta));
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('allow_public_link')) {
      context.handle(
          _allowPublicLinkMeta,
          allowPublicLink.isAcceptableOrUnknown(
              data['allow_public_link']!, _allowPublicLinkMeta));
    }
    if (data.containsKey('memorial_theme')) {
      context.handle(
          _memorialThemeMeta,
          memorialTheme.isAcceptableOrUnknown(
              data['memorial_theme']!, _memorialThemeMeta));
    }
    if (data.containsKey('epitaph')) {
      context.handle(_epitaphMeta,
          epitaph.isAcceptableOrUnknown(data['epitaph']!, _epitaphMeta));
    }
    if (data.containsKey('flower_count')) {
      context.handle(
          _flowerCountMeta,
          flowerCount.isAcceptableOrUnknown(
              data['flower_count']!, _flowerCountMeta));
    }
    if (data.containsKey('candle_count')) {
      context.handle(
          _candleCountMeta,
          candleCount.isAcceptableOrUnknown(
              data['candle_count']!, _candleCountMeta));
    }
    if (data.containsKey('incense_count')) {
      context.handle(
          _incenseCountMeta,
          incenseCount.isAcceptableOrUnknown(
              data['incense_count']!, _incenseCountMeta));
    }
    if (data.containsKey('prayer_count')) {
      context.handle(
          _prayerCountMeta,
          prayerCount.isAcceptableOrUnknown(
              data['prayer_count']!, _prayerCountMeta));
    }
    if (data.containsKey('message_count')) {
      context.handle(
          _messageCountMeta,
          messageCount.isAcceptableOrUnknown(
              data['message_count']!, _messageCountMeta));
    }
    if (data.containsKey('last_memorial_at')) {
      context.handle(
          _lastMemorialAtMeta,
          lastMemorialAt.isAcceptableOrUnknown(
              data['last_memorial_at']!, _lastMemorialAtMeta));
    }
    if (data.containsKey('is_self')) {
      context.handle(_isSelfMeta,
          isSelf.isAcceptableOrUnknown(data['is_self']!, _isSelfMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Person map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Person(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      treeId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tree_id'])!,
      givenName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}given_name'])!,
      surname: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}surname'])!,
      gender: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}gender'])!,
      birthDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}birth_date']),
      birthPrecision: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}birth_precision'])!,
      birthPlace: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}birth_place']),
      deathDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}death_date']),
      deathPrecision: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}death_precision'])!,
      deathPlace: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}death_place']),
      burialPlace: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}burial_place']),
      isLiving: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_living'])!,
      occupation: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}occupation']),
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
      allowPublicLink: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}allow_public_link'])!,
      memorialTheme: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}memorial_theme']),
      epitaph: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}epitaph']),
      flowerCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}flower_count'])!,
      candleCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}candle_count'])!,
      incenseCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}incense_count'])!,
      prayerCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}prayer_count'])!,
      messageCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}message_count'])!,
      lastMemorialAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_memorial_at']),
      isSelf: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_self'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $PersonsTable createAlias(String alias) {
    return $PersonsTable(attachedDatabase, alias);
  }
}

class Person extends DataClass implements Insertable<Person> {
  final String id;
  final String treeId;
  final String givenName;
  final String surname;
  final String gender;
  final DateTime? birthDate;
  final String birthPrecision;
  final String? birthPlace;
  final DateTime? deathDate;
  final String deathPrecision;
  final String? deathPlace;
  final String? burialPlace;
  final bool isLiving;
  final String? occupation;
  final String? note;
  final bool allowPublicLink;
  final String? memorialTheme;
  final String? epitaph;
  final int flowerCount;
  final int candleCount;
  final int incenseCount;
  final int prayerCount;
  final int messageCount;
  final DateTime? lastMemorialAt;

  /// 树的「焦点人物」（如"我"），默认视图居中。
  final bool isSelf;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const Person(
      {required this.id,
      required this.treeId,
      required this.givenName,
      required this.surname,
      required this.gender,
      this.birthDate,
      required this.birthPrecision,
      this.birthPlace,
      this.deathDate,
      required this.deathPrecision,
      this.deathPlace,
      this.burialPlace,
      required this.isLiving,
      this.occupation,
      this.note,
      required this.allowPublicLink,
      this.memorialTheme,
      this.epitaph,
      required this.flowerCount,
      required this.candleCount,
      required this.incenseCount,
      required this.prayerCount,
      required this.messageCount,
      this.lastMemorialAt,
      required this.isSelf,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tree_id'] = Variable<String>(treeId);
    map['given_name'] = Variable<String>(givenName);
    map['surname'] = Variable<String>(surname);
    map['gender'] = Variable<String>(gender);
    if (!nullToAbsent || birthDate != null) {
      map['birth_date'] = Variable<DateTime>(birthDate);
    }
    map['birth_precision'] = Variable<String>(birthPrecision);
    if (!nullToAbsent || birthPlace != null) {
      map['birth_place'] = Variable<String>(birthPlace);
    }
    if (!nullToAbsent || deathDate != null) {
      map['death_date'] = Variable<DateTime>(deathDate);
    }
    map['death_precision'] = Variable<String>(deathPrecision);
    if (!nullToAbsent || deathPlace != null) {
      map['death_place'] = Variable<String>(deathPlace);
    }
    if (!nullToAbsent || burialPlace != null) {
      map['burial_place'] = Variable<String>(burialPlace);
    }
    map['is_living'] = Variable<bool>(isLiving);
    if (!nullToAbsent || occupation != null) {
      map['occupation'] = Variable<String>(occupation);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['allow_public_link'] = Variable<bool>(allowPublicLink);
    if (!nullToAbsent || memorialTheme != null) {
      map['memorial_theme'] = Variable<String>(memorialTheme);
    }
    if (!nullToAbsent || epitaph != null) {
      map['epitaph'] = Variable<String>(epitaph);
    }
    map['flower_count'] = Variable<int>(flowerCount);
    map['candle_count'] = Variable<int>(candleCount);
    map['incense_count'] = Variable<int>(incenseCount);
    map['prayer_count'] = Variable<int>(prayerCount);
    map['message_count'] = Variable<int>(messageCount);
    if (!nullToAbsent || lastMemorialAt != null) {
      map['last_memorial_at'] = Variable<DateTime>(lastMemorialAt);
    }
    map['is_self'] = Variable<bool>(isSelf);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  PersonsCompanion toCompanion(bool nullToAbsent) {
    return PersonsCompanion(
      id: Value(id),
      treeId: Value(treeId),
      givenName: Value(givenName),
      surname: Value(surname),
      gender: Value(gender),
      birthDate: birthDate == null && nullToAbsent
          ? const Value.absent()
          : Value(birthDate),
      birthPrecision: Value(birthPrecision),
      birthPlace: birthPlace == null && nullToAbsent
          ? const Value.absent()
          : Value(birthPlace),
      deathDate: deathDate == null && nullToAbsent
          ? const Value.absent()
          : Value(deathDate),
      deathPrecision: Value(deathPrecision),
      deathPlace: deathPlace == null && nullToAbsent
          ? const Value.absent()
          : Value(deathPlace),
      burialPlace: burialPlace == null && nullToAbsent
          ? const Value.absent()
          : Value(burialPlace),
      isLiving: Value(isLiving),
      occupation: occupation == null && nullToAbsent
          ? const Value.absent()
          : Value(occupation),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      allowPublicLink: Value(allowPublicLink),
      memorialTheme: memorialTheme == null && nullToAbsent
          ? const Value.absent()
          : Value(memorialTheme),
      epitaph: epitaph == null && nullToAbsent
          ? const Value.absent()
          : Value(epitaph),
      flowerCount: Value(flowerCount),
      candleCount: Value(candleCount),
      incenseCount: Value(incenseCount),
      prayerCount: Value(prayerCount),
      messageCount: Value(messageCount),
      lastMemorialAt: lastMemorialAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastMemorialAt),
      isSelf: Value(isSelf),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Person.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Person(
      id: serializer.fromJson<String>(json['id']),
      treeId: serializer.fromJson<String>(json['treeId']),
      givenName: serializer.fromJson<String>(json['givenName']),
      surname: serializer.fromJson<String>(json['surname']),
      gender: serializer.fromJson<String>(json['gender']),
      birthDate: serializer.fromJson<DateTime?>(json['birthDate']),
      birthPrecision: serializer.fromJson<String>(json['birthPrecision']),
      birthPlace: serializer.fromJson<String?>(json['birthPlace']),
      deathDate: serializer.fromJson<DateTime?>(json['deathDate']),
      deathPrecision: serializer.fromJson<String>(json['deathPrecision']),
      deathPlace: serializer.fromJson<String?>(json['deathPlace']),
      burialPlace: serializer.fromJson<String?>(json['burialPlace']),
      isLiving: serializer.fromJson<bool>(json['isLiving']),
      occupation: serializer.fromJson<String?>(json['occupation']),
      note: serializer.fromJson<String?>(json['note']),
      allowPublicLink: serializer.fromJson<bool>(json['allowPublicLink']),
      memorialTheme: serializer.fromJson<String?>(json['memorialTheme']),
      epitaph: serializer.fromJson<String?>(json['epitaph']),
      flowerCount: serializer.fromJson<int>(json['flowerCount']),
      candleCount: serializer.fromJson<int>(json['candleCount']),
      incenseCount: serializer.fromJson<int>(json['incenseCount']),
      prayerCount: serializer.fromJson<int>(json['prayerCount']),
      messageCount: serializer.fromJson<int>(json['messageCount']),
      lastMemorialAt: serializer.fromJson<DateTime?>(json['lastMemorialAt']),
      isSelf: serializer.fromJson<bool>(json['isSelf']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'treeId': serializer.toJson<String>(treeId),
      'givenName': serializer.toJson<String>(givenName),
      'surname': serializer.toJson<String>(surname),
      'gender': serializer.toJson<String>(gender),
      'birthDate': serializer.toJson<DateTime?>(birthDate),
      'birthPrecision': serializer.toJson<String>(birthPrecision),
      'birthPlace': serializer.toJson<String?>(birthPlace),
      'deathDate': serializer.toJson<DateTime?>(deathDate),
      'deathPrecision': serializer.toJson<String>(deathPrecision),
      'deathPlace': serializer.toJson<String?>(deathPlace),
      'burialPlace': serializer.toJson<String?>(burialPlace),
      'isLiving': serializer.toJson<bool>(isLiving),
      'occupation': serializer.toJson<String?>(occupation),
      'note': serializer.toJson<String?>(note),
      'allowPublicLink': serializer.toJson<bool>(allowPublicLink),
      'memorialTheme': serializer.toJson<String?>(memorialTheme),
      'epitaph': serializer.toJson<String?>(epitaph),
      'flowerCount': serializer.toJson<int>(flowerCount),
      'candleCount': serializer.toJson<int>(candleCount),
      'incenseCount': serializer.toJson<int>(incenseCount),
      'prayerCount': serializer.toJson<int>(prayerCount),
      'messageCount': serializer.toJson<int>(messageCount),
      'lastMemorialAt': serializer.toJson<DateTime?>(lastMemorialAt),
      'isSelf': serializer.toJson<bool>(isSelf),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  Person copyWith(
          {String? id,
          String? treeId,
          String? givenName,
          String? surname,
          String? gender,
          Value<DateTime?> birthDate = const Value.absent(),
          String? birthPrecision,
          Value<String?> birthPlace = const Value.absent(),
          Value<DateTime?> deathDate = const Value.absent(),
          String? deathPrecision,
          Value<String?> deathPlace = const Value.absent(),
          Value<String?> burialPlace = const Value.absent(),
          bool? isLiving,
          Value<String?> occupation = const Value.absent(),
          Value<String?> note = const Value.absent(),
          bool? allowPublicLink,
          Value<String?> memorialTheme = const Value.absent(),
          Value<String?> epitaph = const Value.absent(),
          int? flowerCount,
          int? candleCount,
          int? incenseCount,
          int? prayerCount,
          int? messageCount,
          Value<DateTime?> lastMemorialAt = const Value.absent(),
          bool? isSelf,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent()}) =>
      Person(
        id: id ?? this.id,
        treeId: treeId ?? this.treeId,
        givenName: givenName ?? this.givenName,
        surname: surname ?? this.surname,
        gender: gender ?? this.gender,
        birthDate: birthDate.present ? birthDate.value : this.birthDate,
        birthPrecision: birthPrecision ?? this.birthPrecision,
        birthPlace: birthPlace.present ? birthPlace.value : this.birthPlace,
        deathDate: deathDate.present ? deathDate.value : this.deathDate,
        deathPrecision: deathPrecision ?? this.deathPrecision,
        deathPlace: deathPlace.present ? deathPlace.value : this.deathPlace,
        burialPlace: burialPlace.present ? burialPlace.value : this.burialPlace,
        isLiving: isLiving ?? this.isLiving,
        occupation: occupation.present ? occupation.value : this.occupation,
        note: note.present ? note.value : this.note,
        allowPublicLink: allowPublicLink ?? this.allowPublicLink,
        memorialTheme:
            memorialTheme.present ? memorialTheme.value : this.memorialTheme,
        epitaph: epitaph.present ? epitaph.value : this.epitaph,
        flowerCount: flowerCount ?? this.flowerCount,
        candleCount: candleCount ?? this.candleCount,
        incenseCount: incenseCount ?? this.incenseCount,
        prayerCount: prayerCount ?? this.prayerCount,
        messageCount: messageCount ?? this.messageCount,
        lastMemorialAt:
            lastMemorialAt.present ? lastMemorialAt.value : this.lastMemorialAt,
        isSelf: isSelf ?? this.isSelf,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
      );
  Person copyWithCompanion(PersonsCompanion data) {
    return Person(
      id: data.id.present ? data.id.value : this.id,
      treeId: data.treeId.present ? data.treeId.value : this.treeId,
      givenName: data.givenName.present ? data.givenName.value : this.givenName,
      surname: data.surname.present ? data.surname.value : this.surname,
      gender: data.gender.present ? data.gender.value : this.gender,
      birthDate: data.birthDate.present ? data.birthDate.value : this.birthDate,
      birthPrecision: data.birthPrecision.present
          ? data.birthPrecision.value
          : this.birthPrecision,
      birthPlace:
          data.birthPlace.present ? data.birthPlace.value : this.birthPlace,
      deathDate: data.deathDate.present ? data.deathDate.value : this.deathDate,
      deathPrecision: data.deathPrecision.present
          ? data.deathPrecision.value
          : this.deathPrecision,
      deathPlace:
          data.deathPlace.present ? data.deathPlace.value : this.deathPlace,
      burialPlace:
          data.burialPlace.present ? data.burialPlace.value : this.burialPlace,
      isLiving: data.isLiving.present ? data.isLiving.value : this.isLiving,
      occupation:
          data.occupation.present ? data.occupation.value : this.occupation,
      note: data.note.present ? data.note.value : this.note,
      allowPublicLink: data.allowPublicLink.present
          ? data.allowPublicLink.value
          : this.allowPublicLink,
      memorialTheme: data.memorialTheme.present
          ? data.memorialTheme.value
          : this.memorialTheme,
      epitaph: data.epitaph.present ? data.epitaph.value : this.epitaph,
      flowerCount:
          data.flowerCount.present ? data.flowerCount.value : this.flowerCount,
      candleCount:
          data.candleCount.present ? data.candleCount.value : this.candleCount,
      incenseCount: data.incenseCount.present
          ? data.incenseCount.value
          : this.incenseCount,
      prayerCount:
          data.prayerCount.present ? data.prayerCount.value : this.prayerCount,
      messageCount: data.messageCount.present
          ? data.messageCount.value
          : this.messageCount,
      lastMemorialAt: data.lastMemorialAt.present
          ? data.lastMemorialAt.value
          : this.lastMemorialAt,
      isSelf: data.isSelf.present ? data.isSelf.value : this.isSelf,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Person(')
          ..write('id: $id, ')
          ..write('treeId: $treeId, ')
          ..write('givenName: $givenName, ')
          ..write('surname: $surname, ')
          ..write('gender: $gender, ')
          ..write('birthDate: $birthDate, ')
          ..write('birthPrecision: $birthPrecision, ')
          ..write('birthPlace: $birthPlace, ')
          ..write('deathDate: $deathDate, ')
          ..write('deathPrecision: $deathPrecision, ')
          ..write('deathPlace: $deathPlace, ')
          ..write('burialPlace: $burialPlace, ')
          ..write('isLiving: $isLiving, ')
          ..write('occupation: $occupation, ')
          ..write('note: $note, ')
          ..write('allowPublicLink: $allowPublicLink, ')
          ..write('memorialTheme: $memorialTheme, ')
          ..write('epitaph: $epitaph, ')
          ..write('flowerCount: $flowerCount, ')
          ..write('candleCount: $candleCount, ')
          ..write('incenseCount: $incenseCount, ')
          ..write('prayerCount: $prayerCount, ')
          ..write('messageCount: $messageCount, ')
          ..write('lastMemorialAt: $lastMemorialAt, ')
          ..write('isSelf: $isSelf, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        treeId,
        givenName,
        surname,
        gender,
        birthDate,
        birthPrecision,
        birthPlace,
        deathDate,
        deathPrecision,
        deathPlace,
        burialPlace,
        isLiving,
        occupation,
        note,
        allowPublicLink,
        memorialTheme,
        epitaph,
        flowerCount,
        candleCount,
        incenseCount,
        prayerCount,
        messageCount,
        lastMemorialAt,
        isSelf,
        createdAt,
        updatedAt,
        deletedAt
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Person &&
          other.id == this.id &&
          other.treeId == this.treeId &&
          other.givenName == this.givenName &&
          other.surname == this.surname &&
          other.gender == this.gender &&
          other.birthDate == this.birthDate &&
          other.birthPrecision == this.birthPrecision &&
          other.birthPlace == this.birthPlace &&
          other.deathDate == this.deathDate &&
          other.deathPrecision == this.deathPrecision &&
          other.deathPlace == this.deathPlace &&
          other.burialPlace == this.burialPlace &&
          other.isLiving == this.isLiving &&
          other.occupation == this.occupation &&
          other.note == this.note &&
          other.allowPublicLink == this.allowPublicLink &&
          other.memorialTheme == this.memorialTheme &&
          other.epitaph == this.epitaph &&
          other.flowerCount == this.flowerCount &&
          other.candleCount == this.candleCount &&
          other.incenseCount == this.incenseCount &&
          other.prayerCount == this.prayerCount &&
          other.messageCount == this.messageCount &&
          other.lastMemorialAt == this.lastMemorialAt &&
          other.isSelf == this.isSelf &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class PersonsCompanion extends UpdateCompanion<Person> {
  final Value<String> id;
  final Value<String> treeId;
  final Value<String> givenName;
  final Value<String> surname;
  final Value<String> gender;
  final Value<DateTime?> birthDate;
  final Value<String> birthPrecision;
  final Value<String?> birthPlace;
  final Value<DateTime?> deathDate;
  final Value<String> deathPrecision;
  final Value<String?> deathPlace;
  final Value<String?> burialPlace;
  final Value<bool> isLiving;
  final Value<String?> occupation;
  final Value<String?> note;
  final Value<bool> allowPublicLink;
  final Value<String?> memorialTheme;
  final Value<String?> epitaph;
  final Value<int> flowerCount;
  final Value<int> candleCount;
  final Value<int> incenseCount;
  final Value<int> prayerCount;
  final Value<int> messageCount;
  final Value<DateTime?> lastMemorialAt;
  final Value<bool> isSelf;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const PersonsCompanion({
    this.id = const Value.absent(),
    this.treeId = const Value.absent(),
    this.givenName = const Value.absent(),
    this.surname = const Value.absent(),
    this.gender = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.birthPrecision = const Value.absent(),
    this.birthPlace = const Value.absent(),
    this.deathDate = const Value.absent(),
    this.deathPrecision = const Value.absent(),
    this.deathPlace = const Value.absent(),
    this.burialPlace = const Value.absent(),
    this.isLiving = const Value.absent(),
    this.occupation = const Value.absent(),
    this.note = const Value.absent(),
    this.allowPublicLink = const Value.absent(),
    this.memorialTheme = const Value.absent(),
    this.epitaph = const Value.absent(),
    this.flowerCount = const Value.absent(),
    this.candleCount = const Value.absent(),
    this.incenseCount = const Value.absent(),
    this.prayerCount = const Value.absent(),
    this.messageCount = const Value.absent(),
    this.lastMemorialAt = const Value.absent(),
    this.isSelf = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PersonsCompanion.insert({
    this.id = const Value.absent(),
    required String treeId,
    this.givenName = const Value.absent(),
    this.surname = const Value.absent(),
    this.gender = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.birthPrecision = const Value.absent(),
    this.birthPlace = const Value.absent(),
    this.deathDate = const Value.absent(),
    this.deathPrecision = const Value.absent(),
    this.deathPlace = const Value.absent(),
    this.burialPlace = const Value.absent(),
    this.isLiving = const Value.absent(),
    this.occupation = const Value.absent(),
    this.note = const Value.absent(),
    this.allowPublicLink = const Value.absent(),
    this.memorialTheme = const Value.absent(),
    this.epitaph = const Value.absent(),
    this.flowerCount = const Value.absent(),
    this.candleCount = const Value.absent(),
    this.incenseCount = const Value.absent(),
    this.prayerCount = const Value.absent(),
    this.messageCount = const Value.absent(),
    this.lastMemorialAt = const Value.absent(),
    this.isSelf = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : treeId = Value(treeId);
  static Insertable<Person> custom({
    Expression<String>? id,
    Expression<String>? treeId,
    Expression<String>? givenName,
    Expression<String>? surname,
    Expression<String>? gender,
    Expression<DateTime>? birthDate,
    Expression<String>? birthPrecision,
    Expression<String>? birthPlace,
    Expression<DateTime>? deathDate,
    Expression<String>? deathPrecision,
    Expression<String>? deathPlace,
    Expression<String>? burialPlace,
    Expression<bool>? isLiving,
    Expression<String>? occupation,
    Expression<String>? note,
    Expression<bool>? allowPublicLink,
    Expression<String>? memorialTheme,
    Expression<String>? epitaph,
    Expression<int>? flowerCount,
    Expression<int>? candleCount,
    Expression<int>? incenseCount,
    Expression<int>? prayerCount,
    Expression<int>? messageCount,
    Expression<DateTime>? lastMemorialAt,
    Expression<bool>? isSelf,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (treeId != null) 'tree_id': treeId,
      if (givenName != null) 'given_name': givenName,
      if (surname != null) 'surname': surname,
      if (gender != null) 'gender': gender,
      if (birthDate != null) 'birth_date': birthDate,
      if (birthPrecision != null) 'birth_precision': birthPrecision,
      if (birthPlace != null) 'birth_place': birthPlace,
      if (deathDate != null) 'death_date': deathDate,
      if (deathPrecision != null) 'death_precision': deathPrecision,
      if (deathPlace != null) 'death_place': deathPlace,
      if (burialPlace != null) 'burial_place': burialPlace,
      if (isLiving != null) 'is_living': isLiving,
      if (occupation != null) 'occupation': occupation,
      if (note != null) 'note': note,
      if (allowPublicLink != null) 'allow_public_link': allowPublicLink,
      if (memorialTheme != null) 'memorial_theme': memorialTheme,
      if (epitaph != null) 'epitaph': epitaph,
      if (flowerCount != null) 'flower_count': flowerCount,
      if (candleCount != null) 'candle_count': candleCount,
      if (incenseCount != null) 'incense_count': incenseCount,
      if (prayerCount != null) 'prayer_count': prayerCount,
      if (messageCount != null) 'message_count': messageCount,
      if (lastMemorialAt != null) 'last_memorial_at': lastMemorialAt,
      if (isSelf != null) 'is_self': isSelf,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PersonsCompanion copyWith(
      {Value<String>? id,
      Value<String>? treeId,
      Value<String>? givenName,
      Value<String>? surname,
      Value<String>? gender,
      Value<DateTime?>? birthDate,
      Value<String>? birthPrecision,
      Value<String?>? birthPlace,
      Value<DateTime?>? deathDate,
      Value<String>? deathPrecision,
      Value<String?>? deathPlace,
      Value<String?>? burialPlace,
      Value<bool>? isLiving,
      Value<String?>? occupation,
      Value<String?>? note,
      Value<bool>? allowPublicLink,
      Value<String?>? memorialTheme,
      Value<String?>? epitaph,
      Value<int>? flowerCount,
      Value<int>? candleCount,
      Value<int>? incenseCount,
      Value<int>? prayerCount,
      Value<int>? messageCount,
      Value<DateTime?>? lastMemorialAt,
      Value<bool>? isSelf,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<int>? rowid}) {
    return PersonsCompanion(
      id: id ?? this.id,
      treeId: treeId ?? this.treeId,
      givenName: givenName ?? this.givenName,
      surname: surname ?? this.surname,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      birthPrecision: birthPrecision ?? this.birthPrecision,
      birthPlace: birthPlace ?? this.birthPlace,
      deathDate: deathDate ?? this.deathDate,
      deathPrecision: deathPrecision ?? this.deathPrecision,
      deathPlace: deathPlace ?? this.deathPlace,
      burialPlace: burialPlace ?? this.burialPlace,
      isLiving: isLiving ?? this.isLiving,
      occupation: occupation ?? this.occupation,
      note: note ?? this.note,
      allowPublicLink: allowPublicLink ?? this.allowPublicLink,
      memorialTheme: memorialTheme ?? this.memorialTheme,
      epitaph: epitaph ?? this.epitaph,
      flowerCount: flowerCount ?? this.flowerCount,
      candleCount: candleCount ?? this.candleCount,
      incenseCount: incenseCount ?? this.incenseCount,
      prayerCount: prayerCount ?? this.prayerCount,
      messageCount: messageCount ?? this.messageCount,
      lastMemorialAt: lastMemorialAt ?? this.lastMemorialAt,
      isSelf: isSelf ?? this.isSelf,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (treeId.present) {
      map['tree_id'] = Variable<String>(treeId.value);
    }
    if (givenName.present) {
      map['given_name'] = Variable<String>(givenName.value);
    }
    if (surname.present) {
      map['surname'] = Variable<String>(surname.value);
    }
    if (gender.present) {
      map['gender'] = Variable<String>(gender.value);
    }
    if (birthDate.present) {
      map['birth_date'] = Variable<DateTime>(birthDate.value);
    }
    if (birthPrecision.present) {
      map['birth_precision'] = Variable<String>(birthPrecision.value);
    }
    if (birthPlace.present) {
      map['birth_place'] = Variable<String>(birthPlace.value);
    }
    if (deathDate.present) {
      map['death_date'] = Variable<DateTime>(deathDate.value);
    }
    if (deathPrecision.present) {
      map['death_precision'] = Variable<String>(deathPrecision.value);
    }
    if (deathPlace.present) {
      map['death_place'] = Variable<String>(deathPlace.value);
    }
    if (burialPlace.present) {
      map['burial_place'] = Variable<String>(burialPlace.value);
    }
    if (isLiving.present) {
      map['is_living'] = Variable<bool>(isLiving.value);
    }
    if (occupation.present) {
      map['occupation'] = Variable<String>(occupation.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (allowPublicLink.present) {
      map['allow_public_link'] = Variable<bool>(allowPublicLink.value);
    }
    if (memorialTheme.present) {
      map['memorial_theme'] = Variable<String>(memorialTheme.value);
    }
    if (epitaph.present) {
      map['epitaph'] = Variable<String>(epitaph.value);
    }
    if (flowerCount.present) {
      map['flower_count'] = Variable<int>(flowerCount.value);
    }
    if (candleCount.present) {
      map['candle_count'] = Variable<int>(candleCount.value);
    }
    if (incenseCount.present) {
      map['incense_count'] = Variable<int>(incenseCount.value);
    }
    if (prayerCount.present) {
      map['prayer_count'] = Variable<int>(prayerCount.value);
    }
    if (messageCount.present) {
      map['message_count'] = Variable<int>(messageCount.value);
    }
    if (lastMemorialAt.present) {
      map['last_memorial_at'] = Variable<DateTime>(lastMemorialAt.value);
    }
    if (isSelf.present) {
      map['is_self'] = Variable<bool>(isSelf.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PersonsCompanion(')
          ..write('id: $id, ')
          ..write('treeId: $treeId, ')
          ..write('givenName: $givenName, ')
          ..write('surname: $surname, ')
          ..write('gender: $gender, ')
          ..write('birthDate: $birthDate, ')
          ..write('birthPrecision: $birthPrecision, ')
          ..write('birthPlace: $birthPlace, ')
          ..write('deathDate: $deathDate, ')
          ..write('deathPrecision: $deathPrecision, ')
          ..write('deathPlace: $deathPlace, ')
          ..write('burialPlace: $burialPlace, ')
          ..write('isLiving: $isLiving, ')
          ..write('occupation: $occupation, ')
          ..write('note: $note, ')
          ..write('allowPublicLink: $allowPublicLink, ')
          ..write('memorialTheme: $memorialTheme, ')
          ..write('epitaph: $epitaph, ')
          ..write('flowerCount: $flowerCount, ')
          ..write('candleCount: $candleCount, ')
          ..write('incenseCount: $incenseCount, ')
          ..write('prayerCount: $prayerCount, ')
          ..write('messageCount: $messageCount, ')
          ..write('lastMemorialAt: $lastMemorialAt, ')
          ..write('isSelf: $isSelf, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FamiliesTable extends Families with TableInfo<$FamiliesTable, Family> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FamiliesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      clientDefault: newId);
  static const VerificationMeta _treeIdMeta = const VerificationMeta('treeId');
  @override
  late final GeneratedColumn<String> treeId = GeneratedColumn<String>(
      'tree_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _partner1IdMeta =
      const VerificationMeta('partner1Id');
  @override
  late final GeneratedColumn<String> partner1Id = GeneratedColumn<String>(
      'partner1_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _partner2IdMeta =
      const VerificationMeta('partner2Id');
  @override
  late final GeneratedColumn<String> partner2Id = GeneratedColumn<String>(
      'partner2_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _relationTypeMeta =
      const VerificationMeta('relationType');
  @override
  late final GeneratedColumn<String> relationType = GeneratedColumn<String>(
      'relation_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('married'));
  static const VerificationMeta _marriageDateMeta =
      const VerificationMeta('marriageDate');
  @override
  late final GeneratedColumn<DateTime> marriageDate = GeneratedColumn<DateTime>(
      'marriage_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        treeId,
        partner1Id,
        partner2Id,
        relationType,
        marriageDate,
        sortOrder,
        createdAt,
        updatedAt,
        deletedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'families';
  @override
  VerificationContext validateIntegrity(Insertable<Family> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('tree_id')) {
      context.handle(_treeIdMeta,
          treeId.isAcceptableOrUnknown(data['tree_id']!, _treeIdMeta));
    } else if (isInserting) {
      context.missing(_treeIdMeta);
    }
    if (data.containsKey('partner1_id')) {
      context.handle(
          _partner1IdMeta,
          partner1Id.isAcceptableOrUnknown(
              data['partner1_id']!, _partner1IdMeta));
    }
    if (data.containsKey('partner2_id')) {
      context.handle(
          _partner2IdMeta,
          partner2Id.isAcceptableOrUnknown(
              data['partner2_id']!, _partner2IdMeta));
    }
    if (data.containsKey('relation_type')) {
      context.handle(
          _relationTypeMeta,
          relationType.isAcceptableOrUnknown(
              data['relation_type']!, _relationTypeMeta));
    }
    if (data.containsKey('marriage_date')) {
      context.handle(
          _marriageDateMeta,
          marriageDate.isAcceptableOrUnknown(
              data['marriage_date']!, _marriageDateMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Family map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Family(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      treeId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tree_id'])!,
      partner1Id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}partner1_id']),
      partner2Id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}partner2_id']),
      relationType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}relation_type'])!,
      marriageDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}marriage_date']),
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
    );
  }

  @override
  $FamiliesTable createAlias(String alias) {
    return $FamiliesTable(attachedDatabase, alias);
  }
}

class Family extends DataClass implements Insertable<Family> {
  final String id;
  final String treeId;
  final String? partner1Id;
  final String? partner2Id;
  final String relationType;
  final DateTime? marriageDate;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const Family(
      {required this.id,
      required this.treeId,
      this.partner1Id,
      this.partner2Id,
      required this.relationType,
      this.marriageDate,
      required this.sortOrder,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tree_id'] = Variable<String>(treeId);
    if (!nullToAbsent || partner1Id != null) {
      map['partner1_id'] = Variable<String>(partner1Id);
    }
    if (!nullToAbsent || partner2Id != null) {
      map['partner2_id'] = Variable<String>(partner2Id);
    }
    map['relation_type'] = Variable<String>(relationType);
    if (!nullToAbsent || marriageDate != null) {
      map['marriage_date'] = Variable<DateTime>(marriageDate);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  FamiliesCompanion toCompanion(bool nullToAbsent) {
    return FamiliesCompanion(
      id: Value(id),
      treeId: Value(treeId),
      partner1Id: partner1Id == null && nullToAbsent
          ? const Value.absent()
          : Value(partner1Id),
      partner2Id: partner2Id == null && nullToAbsent
          ? const Value.absent()
          : Value(partner2Id),
      relationType: Value(relationType),
      marriageDate: marriageDate == null && nullToAbsent
          ? const Value.absent()
          : Value(marriageDate),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Family.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Family(
      id: serializer.fromJson<String>(json['id']),
      treeId: serializer.fromJson<String>(json['treeId']),
      partner1Id: serializer.fromJson<String?>(json['partner1Id']),
      partner2Id: serializer.fromJson<String?>(json['partner2Id']),
      relationType: serializer.fromJson<String>(json['relationType']),
      marriageDate: serializer.fromJson<DateTime?>(json['marriageDate']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'treeId': serializer.toJson<String>(treeId),
      'partner1Id': serializer.toJson<String?>(partner1Id),
      'partner2Id': serializer.toJson<String?>(partner2Id),
      'relationType': serializer.toJson<String>(relationType),
      'marriageDate': serializer.toJson<DateTime?>(marriageDate),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  Family copyWith(
          {String? id,
          String? treeId,
          Value<String?> partner1Id = const Value.absent(),
          Value<String?> partner2Id = const Value.absent(),
          String? relationType,
          Value<DateTime?> marriageDate = const Value.absent(),
          int? sortOrder,
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent()}) =>
      Family(
        id: id ?? this.id,
        treeId: treeId ?? this.treeId,
        partner1Id: partner1Id.present ? partner1Id.value : this.partner1Id,
        partner2Id: partner2Id.present ? partner2Id.value : this.partner2Id,
        relationType: relationType ?? this.relationType,
        marriageDate:
            marriageDate.present ? marriageDate.value : this.marriageDate,
        sortOrder: sortOrder ?? this.sortOrder,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
      );
  Family copyWithCompanion(FamiliesCompanion data) {
    return Family(
      id: data.id.present ? data.id.value : this.id,
      treeId: data.treeId.present ? data.treeId.value : this.treeId,
      partner1Id:
          data.partner1Id.present ? data.partner1Id.value : this.partner1Id,
      partner2Id:
          data.partner2Id.present ? data.partner2Id.value : this.partner2Id,
      relationType: data.relationType.present
          ? data.relationType.value
          : this.relationType,
      marriageDate: data.marriageDate.present
          ? data.marriageDate.value
          : this.marriageDate,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Family(')
          ..write('id: $id, ')
          ..write('treeId: $treeId, ')
          ..write('partner1Id: $partner1Id, ')
          ..write('partner2Id: $partner2Id, ')
          ..write('relationType: $relationType, ')
          ..write('marriageDate: $marriageDate, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, treeId, partner1Id, partner2Id,
      relationType, marriageDate, sortOrder, createdAt, updatedAt, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Family &&
          other.id == this.id &&
          other.treeId == this.treeId &&
          other.partner1Id == this.partner1Id &&
          other.partner2Id == this.partner2Id &&
          other.relationType == this.relationType &&
          other.marriageDate == this.marriageDate &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class FamiliesCompanion extends UpdateCompanion<Family> {
  final Value<String> id;
  final Value<String> treeId;
  final Value<String?> partner1Id;
  final Value<String?> partner2Id;
  final Value<String> relationType;
  final Value<DateTime?> marriageDate;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const FamiliesCompanion({
    this.id = const Value.absent(),
    this.treeId = const Value.absent(),
    this.partner1Id = const Value.absent(),
    this.partner2Id = const Value.absent(),
    this.relationType = const Value.absent(),
    this.marriageDate = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FamiliesCompanion.insert({
    this.id = const Value.absent(),
    required String treeId,
    this.partner1Id = const Value.absent(),
    this.partner2Id = const Value.absent(),
    this.relationType = const Value.absent(),
    this.marriageDate = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : treeId = Value(treeId);
  static Insertable<Family> custom({
    Expression<String>? id,
    Expression<String>? treeId,
    Expression<String>? partner1Id,
    Expression<String>? partner2Id,
    Expression<String>? relationType,
    Expression<DateTime>? marriageDate,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (treeId != null) 'tree_id': treeId,
      if (partner1Id != null) 'partner1_id': partner1Id,
      if (partner2Id != null) 'partner2_id': partner2Id,
      if (relationType != null) 'relation_type': relationType,
      if (marriageDate != null) 'marriage_date': marriageDate,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FamiliesCompanion copyWith(
      {Value<String>? id,
      Value<String>? treeId,
      Value<String?>? partner1Id,
      Value<String?>? partner2Id,
      Value<String>? relationType,
      Value<DateTime?>? marriageDate,
      Value<int>? sortOrder,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<int>? rowid}) {
    return FamiliesCompanion(
      id: id ?? this.id,
      treeId: treeId ?? this.treeId,
      partner1Id: partner1Id ?? this.partner1Id,
      partner2Id: partner2Id ?? this.partner2Id,
      relationType: relationType ?? this.relationType,
      marriageDate: marriageDate ?? this.marriageDate,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (treeId.present) {
      map['tree_id'] = Variable<String>(treeId.value);
    }
    if (partner1Id.present) {
      map['partner1_id'] = Variable<String>(partner1Id.value);
    }
    if (partner2Id.present) {
      map['partner2_id'] = Variable<String>(partner2Id.value);
    }
    if (relationType.present) {
      map['relation_type'] = Variable<String>(relationType.value);
    }
    if (marriageDate.present) {
      map['marriage_date'] = Variable<DateTime>(marriageDate.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FamiliesCompanion(')
          ..write('id: $id, ')
          ..write('treeId: $treeId, ')
          ..write('partner1Id: $partner1Id, ')
          ..write('partner2Id: $partner2Id, ')
          ..write('relationType: $relationType, ')
          ..write('marriageDate: $marriageDate, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FamilyChildrenTable extends FamilyChildren
    with TableInfo<$FamilyChildrenTable, FamilyChildLink> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FamilyChildrenTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _familyIdMeta =
      const VerificationMeta('familyId');
  @override
  late final GeneratedColumn<String> familyId = GeneratedColumn<String>(
      'family_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _treeIdMeta = const VerificationMeta('treeId');
  @override
  late final GeneratedColumn<String> treeId = GeneratedColumn<String>(
      'tree_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _personIdMeta =
      const VerificationMeta('personId');
  @override
  late final GeneratedColumn<String> personId = GeneratedColumn<String>(
      'person_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _pedigreeMeta =
      const VerificationMeta('pedigree');
  @override
  late final GeneratedColumn<String> pedigree = GeneratedColumn<String>(
      'pedigree', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('birth'));
  @override
  List<GeneratedColumn> get $columns =>
      [familyId, treeId, personId, sortOrder, pedigree];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'family_children';
  @override
  VerificationContext validateIntegrity(Insertable<FamilyChildLink> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('family_id')) {
      context.handle(_familyIdMeta,
          familyId.isAcceptableOrUnknown(data['family_id']!, _familyIdMeta));
    } else if (isInserting) {
      context.missing(_familyIdMeta);
    }
    if (data.containsKey('tree_id')) {
      context.handle(_treeIdMeta,
          treeId.isAcceptableOrUnknown(data['tree_id']!, _treeIdMeta));
    } else if (isInserting) {
      context.missing(_treeIdMeta);
    }
    if (data.containsKey('person_id')) {
      context.handle(_personIdMeta,
          personId.isAcceptableOrUnknown(data['person_id']!, _personIdMeta));
    } else if (isInserting) {
      context.missing(_personIdMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    if (data.containsKey('pedigree')) {
      context.handle(_pedigreeMeta,
          pedigree.isAcceptableOrUnknown(data['pedigree']!, _pedigreeMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {familyId, personId};
  @override
  FamilyChildLink map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FamilyChildLink(
      familyId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}family_id'])!,
      treeId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tree_id'])!,
      personId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}person_id'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      pedigree: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}pedigree'])!,
    );
  }

  @override
  $FamilyChildrenTable createAlias(String alias) {
    return $FamilyChildrenTable(attachedDatabase, alias);
  }
}

class FamilyChildLink extends DataClass implements Insertable<FamilyChildLink> {
  final String familyId;
  final String treeId;
  final String personId;
  final int sortOrder;
  final String pedigree;
  const FamilyChildLink(
      {required this.familyId,
      required this.treeId,
      required this.personId,
      required this.sortOrder,
      required this.pedigree});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['family_id'] = Variable<String>(familyId);
    map['tree_id'] = Variable<String>(treeId);
    map['person_id'] = Variable<String>(personId);
    map['sort_order'] = Variable<int>(sortOrder);
    map['pedigree'] = Variable<String>(pedigree);
    return map;
  }

  FamilyChildrenCompanion toCompanion(bool nullToAbsent) {
    return FamilyChildrenCompanion(
      familyId: Value(familyId),
      treeId: Value(treeId),
      personId: Value(personId),
      sortOrder: Value(sortOrder),
      pedigree: Value(pedigree),
    );
  }

  factory FamilyChildLink.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FamilyChildLink(
      familyId: serializer.fromJson<String>(json['familyId']),
      treeId: serializer.fromJson<String>(json['treeId']),
      personId: serializer.fromJson<String>(json['personId']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      pedigree: serializer.fromJson<String>(json['pedigree']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'familyId': serializer.toJson<String>(familyId),
      'treeId': serializer.toJson<String>(treeId),
      'personId': serializer.toJson<String>(personId),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'pedigree': serializer.toJson<String>(pedigree),
    };
  }

  FamilyChildLink copyWith(
          {String? familyId,
          String? treeId,
          String? personId,
          int? sortOrder,
          String? pedigree}) =>
      FamilyChildLink(
        familyId: familyId ?? this.familyId,
        treeId: treeId ?? this.treeId,
        personId: personId ?? this.personId,
        sortOrder: sortOrder ?? this.sortOrder,
        pedigree: pedigree ?? this.pedigree,
      );
  FamilyChildLink copyWithCompanion(FamilyChildrenCompanion data) {
    return FamilyChildLink(
      familyId: data.familyId.present ? data.familyId.value : this.familyId,
      treeId: data.treeId.present ? data.treeId.value : this.treeId,
      personId: data.personId.present ? data.personId.value : this.personId,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      pedigree: data.pedigree.present ? data.pedigree.value : this.pedigree,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FamilyChildLink(')
          ..write('familyId: $familyId, ')
          ..write('treeId: $treeId, ')
          ..write('personId: $personId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('pedigree: $pedigree')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(familyId, treeId, personId, sortOrder, pedigree);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FamilyChildLink &&
          other.familyId == this.familyId &&
          other.treeId == this.treeId &&
          other.personId == this.personId &&
          other.sortOrder == this.sortOrder &&
          other.pedigree == this.pedigree);
}

class FamilyChildrenCompanion extends UpdateCompanion<FamilyChildLink> {
  final Value<String> familyId;
  final Value<String> treeId;
  final Value<String> personId;
  final Value<int> sortOrder;
  final Value<String> pedigree;
  final Value<int> rowid;
  const FamilyChildrenCompanion({
    this.familyId = const Value.absent(),
    this.treeId = const Value.absent(),
    this.personId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.pedigree = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FamilyChildrenCompanion.insert({
    required String familyId,
    required String treeId,
    required String personId,
    this.sortOrder = const Value.absent(),
    this.pedigree = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : familyId = Value(familyId),
        treeId = Value(treeId),
        personId = Value(personId);
  static Insertable<FamilyChildLink> custom({
    Expression<String>? familyId,
    Expression<String>? treeId,
    Expression<String>? personId,
    Expression<int>? sortOrder,
    Expression<String>? pedigree,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (familyId != null) 'family_id': familyId,
      if (treeId != null) 'tree_id': treeId,
      if (personId != null) 'person_id': personId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (pedigree != null) 'pedigree': pedigree,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FamilyChildrenCompanion copyWith(
      {Value<String>? familyId,
      Value<String>? treeId,
      Value<String>? personId,
      Value<int>? sortOrder,
      Value<String>? pedigree,
      Value<int>? rowid}) {
    return FamilyChildrenCompanion(
      familyId: familyId ?? this.familyId,
      treeId: treeId ?? this.treeId,
      personId: personId ?? this.personId,
      sortOrder: sortOrder ?? this.sortOrder,
      pedigree: pedigree ?? this.pedigree,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (familyId.present) {
      map['family_id'] = Variable<String>(familyId.value);
    }
    if (treeId.present) {
      map['tree_id'] = Variable<String>(treeId.value);
    }
    if (personId.present) {
      map['person_id'] = Variable<String>(personId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (pedigree.present) {
      map['pedigree'] = Variable<String>(pedigree.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FamilyChildrenCompanion(')
          ..write('familyId: $familyId, ')
          ..write('treeId: $treeId, ')
          ..write('personId: $personId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('pedigree: $pedigree, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MemorialMessagesTable extends MemorialMessages
    with TableInfo<$MemorialMessagesTable, MemorialMessage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MemorialMessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      clientDefault: newId);
  static const VerificationMeta _treeIdMeta = const VerificationMeta('treeId');
  @override
  late final GeneratedColumn<String> treeId = GeneratedColumn<String>(
      'tree_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _personIdMeta =
      const VerificationMeta('personId');
  @override
  late final GeneratedColumn<String> personId = GeneratedColumn<String>(
      'person_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _authorNameMeta =
      const VerificationMeta('authorName');
  @override
  late final GeneratedColumn<String> authorName = GeneratedColumn<String>(
      'author_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isAnonymousMeta =
      const VerificationMeta('isAnonymous');
  @override
  late final GeneratedColumn<bool> isAnonymous = GeneratedColumn<bool>(
      'is_anonymous', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_anonymous" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
      'body', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _likeCountMeta =
      const VerificationMeta('likeCount');
  @override
  late final GeneratedColumn<int> likeCount = GeneratedColumn<int>(
      'like_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _likedByMeMeta =
      const VerificationMeta('likedByMe');
  @override
  late final GeneratedColumn<bool> likedByMe = GeneratedColumn<bool>(
      'liked_by_me', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("liked_by_me" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        treeId,
        personId,
        authorName,
        isAnonymous,
        body,
        likeCount,
        likedByMe,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'memorial_messages';
  @override
  VerificationContext validateIntegrity(Insertable<MemorialMessage> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('tree_id')) {
      context.handle(_treeIdMeta,
          treeId.isAcceptableOrUnknown(data['tree_id']!, _treeIdMeta));
    } else if (isInserting) {
      context.missing(_treeIdMeta);
    }
    if (data.containsKey('person_id')) {
      context.handle(_personIdMeta,
          personId.isAcceptableOrUnknown(data['person_id']!, _personIdMeta));
    } else if (isInserting) {
      context.missing(_personIdMeta);
    }
    if (data.containsKey('author_name')) {
      context.handle(
          _authorNameMeta,
          authorName.isAcceptableOrUnknown(
              data['author_name']!, _authorNameMeta));
    } else if (isInserting) {
      context.missing(_authorNameMeta);
    }
    if (data.containsKey('is_anonymous')) {
      context.handle(
          _isAnonymousMeta,
          isAnonymous.isAcceptableOrUnknown(
              data['is_anonymous']!, _isAnonymousMeta));
    }
    if (data.containsKey('body')) {
      context.handle(
          _bodyMeta, body.isAcceptableOrUnknown(data['body']!, _bodyMeta));
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('like_count')) {
      context.handle(_likeCountMeta,
          likeCount.isAcceptableOrUnknown(data['like_count']!, _likeCountMeta));
    }
    if (data.containsKey('liked_by_me')) {
      context.handle(
          _likedByMeMeta,
          likedByMe.isAcceptableOrUnknown(
              data['liked_by_me']!, _likedByMeMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MemorialMessage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MemorialMessage(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      treeId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tree_id'])!,
      personId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}person_id'])!,
      authorName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}author_name'])!,
      isAnonymous: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_anonymous'])!,
      body: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}body'])!,
      likeCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}like_count'])!,
      likedByMe: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}liked_by_me'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $MemorialMessagesTable createAlias(String alias) {
    return $MemorialMessagesTable(attachedDatabase, alias);
  }
}

class MemorialMessage extends DataClass implements Insertable<MemorialMessage> {
  final String id;
  final String treeId;
  final String personId;
  final String authorName;
  final bool isAnonymous;
  final String body;
  final int likeCount;
  final bool likedByMe;
  final DateTime createdAt;
  const MemorialMessage(
      {required this.id,
      required this.treeId,
      required this.personId,
      required this.authorName,
      required this.isAnonymous,
      required this.body,
      required this.likeCount,
      required this.likedByMe,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tree_id'] = Variable<String>(treeId);
    map['person_id'] = Variable<String>(personId);
    map['author_name'] = Variable<String>(authorName);
    map['is_anonymous'] = Variable<bool>(isAnonymous);
    map['body'] = Variable<String>(body);
    map['like_count'] = Variable<int>(likeCount);
    map['liked_by_me'] = Variable<bool>(likedByMe);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MemorialMessagesCompanion toCompanion(bool nullToAbsent) {
    return MemorialMessagesCompanion(
      id: Value(id),
      treeId: Value(treeId),
      personId: Value(personId),
      authorName: Value(authorName),
      isAnonymous: Value(isAnonymous),
      body: Value(body),
      likeCount: Value(likeCount),
      likedByMe: Value(likedByMe),
      createdAt: Value(createdAt),
    );
  }

  factory MemorialMessage.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MemorialMessage(
      id: serializer.fromJson<String>(json['id']),
      treeId: serializer.fromJson<String>(json['treeId']),
      personId: serializer.fromJson<String>(json['personId']),
      authorName: serializer.fromJson<String>(json['authorName']),
      isAnonymous: serializer.fromJson<bool>(json['isAnonymous']),
      body: serializer.fromJson<String>(json['body']),
      likeCount: serializer.fromJson<int>(json['likeCount']),
      likedByMe: serializer.fromJson<bool>(json['likedByMe']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'treeId': serializer.toJson<String>(treeId),
      'personId': serializer.toJson<String>(personId),
      'authorName': serializer.toJson<String>(authorName),
      'isAnonymous': serializer.toJson<bool>(isAnonymous),
      'body': serializer.toJson<String>(body),
      'likeCount': serializer.toJson<int>(likeCount),
      'likedByMe': serializer.toJson<bool>(likedByMe),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  MemorialMessage copyWith(
          {String? id,
          String? treeId,
          String? personId,
          String? authorName,
          bool? isAnonymous,
          String? body,
          int? likeCount,
          bool? likedByMe,
          DateTime? createdAt}) =>
      MemorialMessage(
        id: id ?? this.id,
        treeId: treeId ?? this.treeId,
        personId: personId ?? this.personId,
        authorName: authorName ?? this.authorName,
        isAnonymous: isAnonymous ?? this.isAnonymous,
        body: body ?? this.body,
        likeCount: likeCount ?? this.likeCount,
        likedByMe: likedByMe ?? this.likedByMe,
        createdAt: createdAt ?? this.createdAt,
      );
  MemorialMessage copyWithCompanion(MemorialMessagesCompanion data) {
    return MemorialMessage(
      id: data.id.present ? data.id.value : this.id,
      treeId: data.treeId.present ? data.treeId.value : this.treeId,
      personId: data.personId.present ? data.personId.value : this.personId,
      authorName:
          data.authorName.present ? data.authorName.value : this.authorName,
      isAnonymous:
          data.isAnonymous.present ? data.isAnonymous.value : this.isAnonymous,
      body: data.body.present ? data.body.value : this.body,
      likeCount: data.likeCount.present ? data.likeCount.value : this.likeCount,
      likedByMe: data.likedByMe.present ? data.likedByMe.value : this.likedByMe,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MemorialMessage(')
          ..write('id: $id, ')
          ..write('treeId: $treeId, ')
          ..write('personId: $personId, ')
          ..write('authorName: $authorName, ')
          ..write('isAnonymous: $isAnonymous, ')
          ..write('body: $body, ')
          ..write('likeCount: $likeCount, ')
          ..write('likedByMe: $likedByMe, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, treeId, personId, authorName, isAnonymous,
      body, likeCount, likedByMe, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MemorialMessage &&
          other.id == this.id &&
          other.treeId == this.treeId &&
          other.personId == this.personId &&
          other.authorName == this.authorName &&
          other.isAnonymous == this.isAnonymous &&
          other.body == this.body &&
          other.likeCount == this.likeCount &&
          other.likedByMe == this.likedByMe &&
          other.createdAt == this.createdAt);
}

class MemorialMessagesCompanion extends UpdateCompanion<MemorialMessage> {
  final Value<String> id;
  final Value<String> treeId;
  final Value<String> personId;
  final Value<String> authorName;
  final Value<bool> isAnonymous;
  final Value<String> body;
  final Value<int> likeCount;
  final Value<bool> likedByMe;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const MemorialMessagesCompanion({
    this.id = const Value.absent(),
    this.treeId = const Value.absent(),
    this.personId = const Value.absent(),
    this.authorName = const Value.absent(),
    this.isAnonymous = const Value.absent(),
    this.body = const Value.absent(),
    this.likeCount = const Value.absent(),
    this.likedByMe = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MemorialMessagesCompanion.insert({
    this.id = const Value.absent(),
    required String treeId,
    required String personId,
    required String authorName,
    this.isAnonymous = const Value.absent(),
    required String body,
    this.likeCount = const Value.absent(),
    this.likedByMe = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : treeId = Value(treeId),
        personId = Value(personId),
        authorName = Value(authorName),
        body = Value(body);
  static Insertable<MemorialMessage> custom({
    Expression<String>? id,
    Expression<String>? treeId,
    Expression<String>? personId,
    Expression<String>? authorName,
    Expression<bool>? isAnonymous,
    Expression<String>? body,
    Expression<int>? likeCount,
    Expression<bool>? likedByMe,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (treeId != null) 'tree_id': treeId,
      if (personId != null) 'person_id': personId,
      if (authorName != null) 'author_name': authorName,
      if (isAnonymous != null) 'is_anonymous': isAnonymous,
      if (body != null) 'body': body,
      if (likeCount != null) 'like_count': likeCount,
      if (likedByMe != null) 'liked_by_me': likedByMe,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MemorialMessagesCompanion copyWith(
      {Value<String>? id,
      Value<String>? treeId,
      Value<String>? personId,
      Value<String>? authorName,
      Value<bool>? isAnonymous,
      Value<String>? body,
      Value<int>? likeCount,
      Value<bool>? likedByMe,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return MemorialMessagesCompanion(
      id: id ?? this.id,
      treeId: treeId ?? this.treeId,
      personId: personId ?? this.personId,
      authorName: authorName ?? this.authorName,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      body: body ?? this.body,
      likeCount: likeCount ?? this.likeCount,
      likedByMe: likedByMe ?? this.likedByMe,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (treeId.present) {
      map['tree_id'] = Variable<String>(treeId.value);
    }
    if (personId.present) {
      map['person_id'] = Variable<String>(personId.value);
    }
    if (authorName.present) {
      map['author_name'] = Variable<String>(authorName.value);
    }
    if (isAnonymous.present) {
      map['is_anonymous'] = Variable<bool>(isAnonymous.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (likeCount.present) {
      map['like_count'] = Variable<int>(likeCount.value);
    }
    if (likedByMe.present) {
      map['liked_by_me'] = Variable<bool>(likedByMe.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MemorialMessagesCompanion(')
          ..write('id: $id, ')
          ..write('treeId: $treeId, ')
          ..write('personId: $personId, ')
          ..write('authorName: $authorName, ')
          ..write('isAnonymous: $isAnonymous, ')
          ..write('body: $body, ')
          ..write('likeCount: $likeCount, ')
          ..write('likedByMe: $likedByMe, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TreesTable trees = $TreesTable(this);
  late final $PersonsTable persons = $PersonsTable(this);
  late final $FamiliesTable families = $FamiliesTable(this);
  late final $FamilyChildrenTable familyChildren = $FamilyChildrenTable(this);
  late final $MemorialMessagesTable memorialMessages =
      $MemorialMessagesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [trees, persons, families, familyChildren, memorialMessages];
}

typedef $$TreesTableCreateCompanionBuilder = TreesCompanion Function({
  Value<String> id,
  required String name,
  Value<String?> description,
  Value<bool> isDemo,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});
typedef $$TreesTableUpdateCompanionBuilder = TreesCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String?> description,
  Value<bool> isDemo,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});

class $$TreesTableFilterComposer extends Composer<_$AppDatabase, $TreesTable> {
  $$TreesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDemo => $composableBuilder(
      column: $table.isDemo, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));
}

class $$TreesTableOrderingComposer
    extends Composer<_$AppDatabase, $TreesTable> {
  $$TreesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDemo => $composableBuilder(
      column: $table.isDemo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));
}

class $$TreesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TreesTable> {
  $$TreesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<bool> get isDemo =>
      $composableBuilder(column: $table.isDemo, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$TreesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TreesTable,
    Tree,
    $$TreesTableFilterComposer,
    $$TreesTableOrderingComposer,
    $$TreesTableAnnotationComposer,
    $$TreesTableCreateCompanionBuilder,
    $$TreesTableUpdateCompanionBuilder,
    (Tree, BaseReferences<_$AppDatabase, $TreesTable, Tree>),
    Tree,
    PrefetchHooks Function()> {
  $$TreesTableTableManager(_$AppDatabase db, $TreesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TreesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TreesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TreesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<bool> isDemo = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TreesCompanion(
            id: id,
            name: name,
            description: description,
            isDemo: isDemo,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            Value<String> id = const Value.absent(),
            required String name,
            Value<String?> description = const Value.absent(),
            Value<bool> isDemo = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TreesCompanion.insert(
            id: id,
            name: name,
            description: description,
            isDemo: isDemo,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TreesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TreesTable,
    Tree,
    $$TreesTableFilterComposer,
    $$TreesTableOrderingComposer,
    $$TreesTableAnnotationComposer,
    $$TreesTableCreateCompanionBuilder,
    $$TreesTableUpdateCompanionBuilder,
    (Tree, BaseReferences<_$AppDatabase, $TreesTable, Tree>),
    Tree,
    PrefetchHooks Function()>;
typedef $$PersonsTableCreateCompanionBuilder = PersonsCompanion Function({
  Value<String> id,
  required String treeId,
  Value<String> givenName,
  Value<String> surname,
  Value<String> gender,
  Value<DateTime?> birthDate,
  Value<String> birthPrecision,
  Value<String?> birthPlace,
  Value<DateTime?> deathDate,
  Value<String> deathPrecision,
  Value<String?> deathPlace,
  Value<String?> burialPlace,
  Value<bool> isLiving,
  Value<String?> occupation,
  Value<String?> note,
  Value<bool> allowPublicLink,
  Value<String?> memorialTheme,
  Value<String?> epitaph,
  Value<int> flowerCount,
  Value<int> candleCount,
  Value<int> incenseCount,
  Value<int> prayerCount,
  Value<int> messageCount,
  Value<DateTime?> lastMemorialAt,
  Value<bool> isSelf,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});
typedef $$PersonsTableUpdateCompanionBuilder = PersonsCompanion Function({
  Value<String> id,
  Value<String> treeId,
  Value<String> givenName,
  Value<String> surname,
  Value<String> gender,
  Value<DateTime?> birthDate,
  Value<String> birthPrecision,
  Value<String?> birthPlace,
  Value<DateTime?> deathDate,
  Value<String> deathPrecision,
  Value<String?> deathPlace,
  Value<String?> burialPlace,
  Value<bool> isLiving,
  Value<String?> occupation,
  Value<String?> note,
  Value<bool> allowPublicLink,
  Value<String?> memorialTheme,
  Value<String?> epitaph,
  Value<int> flowerCount,
  Value<int> candleCount,
  Value<int> incenseCount,
  Value<int> prayerCount,
  Value<int> messageCount,
  Value<DateTime?> lastMemorialAt,
  Value<bool> isSelf,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});

class $$PersonsTableFilterComposer
    extends Composer<_$AppDatabase, $PersonsTable> {
  $$PersonsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get treeId => $composableBuilder(
      column: $table.treeId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get givenName => $composableBuilder(
      column: $table.givenName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get surname => $composableBuilder(
      column: $table.surname, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get gender => $composableBuilder(
      column: $table.gender, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get birthDate => $composableBuilder(
      column: $table.birthDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get birthPrecision => $composableBuilder(
      column: $table.birthPrecision,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get birthPlace => $composableBuilder(
      column: $table.birthPlace, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deathDate => $composableBuilder(
      column: $table.deathDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deathPrecision => $composableBuilder(
      column: $table.deathPrecision,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deathPlace => $composableBuilder(
      column: $table.deathPlace, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get burialPlace => $composableBuilder(
      column: $table.burialPlace, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isLiving => $composableBuilder(
      column: $table.isLiving, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get occupation => $composableBuilder(
      column: $table.occupation, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get allowPublicLink => $composableBuilder(
      column: $table.allowPublicLink,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get memorialTheme => $composableBuilder(
      column: $table.memorialTheme, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get epitaph => $composableBuilder(
      column: $table.epitaph, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get flowerCount => $composableBuilder(
      column: $table.flowerCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get candleCount => $composableBuilder(
      column: $table.candleCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get incenseCount => $composableBuilder(
      column: $table.incenseCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get prayerCount => $composableBuilder(
      column: $table.prayerCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get messageCount => $composableBuilder(
      column: $table.messageCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastMemorialAt => $composableBuilder(
      column: $table.lastMemorialAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSelf => $composableBuilder(
      column: $table.isSelf, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));
}

class $$PersonsTableOrderingComposer
    extends Composer<_$AppDatabase, $PersonsTable> {
  $$PersonsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get treeId => $composableBuilder(
      column: $table.treeId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get givenName => $composableBuilder(
      column: $table.givenName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get surname => $composableBuilder(
      column: $table.surname, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get gender => $composableBuilder(
      column: $table.gender, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get birthDate => $composableBuilder(
      column: $table.birthDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get birthPrecision => $composableBuilder(
      column: $table.birthPrecision,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get birthPlace => $composableBuilder(
      column: $table.birthPlace, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deathDate => $composableBuilder(
      column: $table.deathDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deathPrecision => $composableBuilder(
      column: $table.deathPrecision,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deathPlace => $composableBuilder(
      column: $table.deathPlace, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get burialPlace => $composableBuilder(
      column: $table.burialPlace, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isLiving => $composableBuilder(
      column: $table.isLiving, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get occupation => $composableBuilder(
      column: $table.occupation, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get allowPublicLink => $composableBuilder(
      column: $table.allowPublicLink,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get memorialTheme => $composableBuilder(
      column: $table.memorialTheme,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get epitaph => $composableBuilder(
      column: $table.epitaph, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get flowerCount => $composableBuilder(
      column: $table.flowerCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get candleCount => $composableBuilder(
      column: $table.candleCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get incenseCount => $composableBuilder(
      column: $table.incenseCount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get prayerCount => $composableBuilder(
      column: $table.prayerCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get messageCount => $composableBuilder(
      column: $table.messageCount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastMemorialAt => $composableBuilder(
      column: $table.lastMemorialAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSelf => $composableBuilder(
      column: $table.isSelf, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));
}

class $$PersonsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PersonsTable> {
  $$PersonsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get treeId =>
      $composableBuilder(column: $table.treeId, builder: (column) => column);

  GeneratedColumn<String> get givenName =>
      $composableBuilder(column: $table.givenName, builder: (column) => column);

  GeneratedColumn<String> get surname =>
      $composableBuilder(column: $table.surname, builder: (column) => column);

  GeneratedColumn<String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<DateTime> get birthDate =>
      $composableBuilder(column: $table.birthDate, builder: (column) => column);

  GeneratedColumn<String> get birthPrecision => $composableBuilder(
      column: $table.birthPrecision, builder: (column) => column);

  GeneratedColumn<String> get birthPlace => $composableBuilder(
      column: $table.birthPlace, builder: (column) => column);

  GeneratedColumn<DateTime> get deathDate =>
      $composableBuilder(column: $table.deathDate, builder: (column) => column);

  GeneratedColumn<String> get deathPrecision => $composableBuilder(
      column: $table.deathPrecision, builder: (column) => column);

  GeneratedColumn<String> get deathPlace => $composableBuilder(
      column: $table.deathPlace, builder: (column) => column);

  GeneratedColumn<String> get burialPlace => $composableBuilder(
      column: $table.burialPlace, builder: (column) => column);

  GeneratedColumn<bool> get isLiving =>
      $composableBuilder(column: $table.isLiving, builder: (column) => column);

  GeneratedColumn<String> get occupation => $composableBuilder(
      column: $table.occupation, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<bool> get allowPublicLink => $composableBuilder(
      column: $table.allowPublicLink, builder: (column) => column);

  GeneratedColumn<String> get memorialTheme => $composableBuilder(
      column: $table.memorialTheme, builder: (column) => column);

  GeneratedColumn<String> get epitaph =>
      $composableBuilder(column: $table.epitaph, builder: (column) => column);

  GeneratedColumn<int> get flowerCount => $composableBuilder(
      column: $table.flowerCount, builder: (column) => column);

  GeneratedColumn<int> get candleCount => $composableBuilder(
      column: $table.candleCount, builder: (column) => column);

  GeneratedColumn<int> get incenseCount => $composableBuilder(
      column: $table.incenseCount, builder: (column) => column);

  GeneratedColumn<int> get prayerCount => $composableBuilder(
      column: $table.prayerCount, builder: (column) => column);

  GeneratedColumn<int> get messageCount => $composableBuilder(
      column: $table.messageCount, builder: (column) => column);

  GeneratedColumn<DateTime> get lastMemorialAt => $composableBuilder(
      column: $table.lastMemorialAt, builder: (column) => column);

  GeneratedColumn<bool> get isSelf =>
      $composableBuilder(column: $table.isSelf, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$PersonsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PersonsTable,
    Person,
    $$PersonsTableFilterComposer,
    $$PersonsTableOrderingComposer,
    $$PersonsTableAnnotationComposer,
    $$PersonsTableCreateCompanionBuilder,
    $$PersonsTableUpdateCompanionBuilder,
    (Person, BaseReferences<_$AppDatabase, $PersonsTable, Person>),
    Person,
    PrefetchHooks Function()> {
  $$PersonsTableTableManager(_$AppDatabase db, $PersonsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PersonsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PersonsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PersonsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> treeId = const Value.absent(),
            Value<String> givenName = const Value.absent(),
            Value<String> surname = const Value.absent(),
            Value<String> gender = const Value.absent(),
            Value<DateTime?> birthDate = const Value.absent(),
            Value<String> birthPrecision = const Value.absent(),
            Value<String?> birthPlace = const Value.absent(),
            Value<DateTime?> deathDate = const Value.absent(),
            Value<String> deathPrecision = const Value.absent(),
            Value<String?> deathPlace = const Value.absent(),
            Value<String?> burialPlace = const Value.absent(),
            Value<bool> isLiving = const Value.absent(),
            Value<String?> occupation = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<bool> allowPublicLink = const Value.absent(),
            Value<String?> memorialTheme = const Value.absent(),
            Value<String?> epitaph = const Value.absent(),
            Value<int> flowerCount = const Value.absent(),
            Value<int> candleCount = const Value.absent(),
            Value<int> incenseCount = const Value.absent(),
            Value<int> prayerCount = const Value.absent(),
            Value<int> messageCount = const Value.absent(),
            Value<DateTime?> lastMemorialAt = const Value.absent(),
            Value<bool> isSelf = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PersonsCompanion(
            id: id,
            treeId: treeId,
            givenName: givenName,
            surname: surname,
            gender: gender,
            birthDate: birthDate,
            birthPrecision: birthPrecision,
            birthPlace: birthPlace,
            deathDate: deathDate,
            deathPrecision: deathPrecision,
            deathPlace: deathPlace,
            burialPlace: burialPlace,
            isLiving: isLiving,
            occupation: occupation,
            note: note,
            allowPublicLink: allowPublicLink,
            memorialTheme: memorialTheme,
            epitaph: epitaph,
            flowerCount: flowerCount,
            candleCount: candleCount,
            incenseCount: incenseCount,
            prayerCount: prayerCount,
            messageCount: messageCount,
            lastMemorialAt: lastMemorialAt,
            isSelf: isSelf,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            Value<String> id = const Value.absent(),
            required String treeId,
            Value<String> givenName = const Value.absent(),
            Value<String> surname = const Value.absent(),
            Value<String> gender = const Value.absent(),
            Value<DateTime?> birthDate = const Value.absent(),
            Value<String> birthPrecision = const Value.absent(),
            Value<String?> birthPlace = const Value.absent(),
            Value<DateTime?> deathDate = const Value.absent(),
            Value<String> deathPrecision = const Value.absent(),
            Value<String?> deathPlace = const Value.absent(),
            Value<String?> burialPlace = const Value.absent(),
            Value<bool> isLiving = const Value.absent(),
            Value<String?> occupation = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<bool> allowPublicLink = const Value.absent(),
            Value<String?> memorialTheme = const Value.absent(),
            Value<String?> epitaph = const Value.absent(),
            Value<int> flowerCount = const Value.absent(),
            Value<int> candleCount = const Value.absent(),
            Value<int> incenseCount = const Value.absent(),
            Value<int> prayerCount = const Value.absent(),
            Value<int> messageCount = const Value.absent(),
            Value<DateTime?> lastMemorialAt = const Value.absent(),
            Value<bool> isSelf = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PersonsCompanion.insert(
            id: id,
            treeId: treeId,
            givenName: givenName,
            surname: surname,
            gender: gender,
            birthDate: birthDate,
            birthPrecision: birthPrecision,
            birthPlace: birthPlace,
            deathDate: deathDate,
            deathPrecision: deathPrecision,
            deathPlace: deathPlace,
            burialPlace: burialPlace,
            isLiving: isLiving,
            occupation: occupation,
            note: note,
            allowPublicLink: allowPublicLink,
            memorialTheme: memorialTheme,
            epitaph: epitaph,
            flowerCount: flowerCount,
            candleCount: candleCount,
            incenseCount: incenseCount,
            prayerCount: prayerCount,
            messageCount: messageCount,
            lastMemorialAt: lastMemorialAt,
            isSelf: isSelf,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PersonsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PersonsTable,
    Person,
    $$PersonsTableFilterComposer,
    $$PersonsTableOrderingComposer,
    $$PersonsTableAnnotationComposer,
    $$PersonsTableCreateCompanionBuilder,
    $$PersonsTableUpdateCompanionBuilder,
    (Person, BaseReferences<_$AppDatabase, $PersonsTable, Person>),
    Person,
    PrefetchHooks Function()>;
typedef $$FamiliesTableCreateCompanionBuilder = FamiliesCompanion Function({
  Value<String> id,
  required String treeId,
  Value<String?> partner1Id,
  Value<String?> partner2Id,
  Value<String> relationType,
  Value<DateTime?> marriageDate,
  Value<int> sortOrder,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});
typedef $$FamiliesTableUpdateCompanionBuilder = FamiliesCompanion Function({
  Value<String> id,
  Value<String> treeId,
  Value<String?> partner1Id,
  Value<String?> partner2Id,
  Value<String> relationType,
  Value<DateTime?> marriageDate,
  Value<int> sortOrder,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rowid,
});

class $$FamiliesTableFilterComposer
    extends Composer<_$AppDatabase, $FamiliesTable> {
  $$FamiliesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get treeId => $composableBuilder(
      column: $table.treeId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get partner1Id => $composableBuilder(
      column: $table.partner1Id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get partner2Id => $composableBuilder(
      column: $table.partner2Id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get relationType => $composableBuilder(
      column: $table.relationType, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get marriageDate => $composableBuilder(
      column: $table.marriageDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));
}

class $$FamiliesTableOrderingComposer
    extends Composer<_$AppDatabase, $FamiliesTable> {
  $$FamiliesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get treeId => $composableBuilder(
      column: $table.treeId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get partner1Id => $composableBuilder(
      column: $table.partner1Id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get partner2Id => $composableBuilder(
      column: $table.partner2Id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get relationType => $composableBuilder(
      column: $table.relationType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get marriageDate => $composableBuilder(
      column: $table.marriageDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));
}

class $$FamiliesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FamiliesTable> {
  $$FamiliesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get treeId =>
      $composableBuilder(column: $table.treeId, builder: (column) => column);

  GeneratedColumn<String> get partner1Id => $composableBuilder(
      column: $table.partner1Id, builder: (column) => column);

  GeneratedColumn<String> get partner2Id => $composableBuilder(
      column: $table.partner2Id, builder: (column) => column);

  GeneratedColumn<String> get relationType => $composableBuilder(
      column: $table.relationType, builder: (column) => column);

  GeneratedColumn<DateTime> get marriageDate => $composableBuilder(
      column: $table.marriageDate, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$FamiliesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FamiliesTable,
    Family,
    $$FamiliesTableFilterComposer,
    $$FamiliesTableOrderingComposer,
    $$FamiliesTableAnnotationComposer,
    $$FamiliesTableCreateCompanionBuilder,
    $$FamiliesTableUpdateCompanionBuilder,
    (Family, BaseReferences<_$AppDatabase, $FamiliesTable, Family>),
    Family,
    PrefetchHooks Function()> {
  $$FamiliesTableTableManager(_$AppDatabase db, $FamiliesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FamiliesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FamiliesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FamiliesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> treeId = const Value.absent(),
            Value<String?> partner1Id = const Value.absent(),
            Value<String?> partner2Id = const Value.absent(),
            Value<String> relationType = const Value.absent(),
            Value<DateTime?> marriageDate = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FamiliesCompanion(
            id: id,
            treeId: treeId,
            partner1Id: partner1Id,
            partner2Id: partner2Id,
            relationType: relationType,
            marriageDate: marriageDate,
            sortOrder: sortOrder,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            Value<String> id = const Value.absent(),
            required String treeId,
            Value<String?> partner1Id = const Value.absent(),
            Value<String?> partner2Id = const Value.absent(),
            Value<String> relationType = const Value.absent(),
            Value<DateTime?> marriageDate = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FamiliesCompanion.insert(
            id: id,
            treeId: treeId,
            partner1Id: partner1Id,
            partner2Id: partner2Id,
            relationType: relationType,
            marriageDate: marriageDate,
            sortOrder: sortOrder,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$FamiliesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FamiliesTable,
    Family,
    $$FamiliesTableFilterComposer,
    $$FamiliesTableOrderingComposer,
    $$FamiliesTableAnnotationComposer,
    $$FamiliesTableCreateCompanionBuilder,
    $$FamiliesTableUpdateCompanionBuilder,
    (Family, BaseReferences<_$AppDatabase, $FamiliesTable, Family>),
    Family,
    PrefetchHooks Function()>;
typedef $$FamilyChildrenTableCreateCompanionBuilder = FamilyChildrenCompanion
    Function({
  required String familyId,
  required String treeId,
  required String personId,
  Value<int> sortOrder,
  Value<String> pedigree,
  Value<int> rowid,
});
typedef $$FamilyChildrenTableUpdateCompanionBuilder = FamilyChildrenCompanion
    Function({
  Value<String> familyId,
  Value<String> treeId,
  Value<String> personId,
  Value<int> sortOrder,
  Value<String> pedigree,
  Value<int> rowid,
});

class $$FamilyChildrenTableFilterComposer
    extends Composer<_$AppDatabase, $FamilyChildrenTable> {
  $$FamilyChildrenTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get familyId => $composableBuilder(
      column: $table.familyId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get treeId => $composableBuilder(
      column: $table.treeId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get personId => $composableBuilder(
      column: $table.personId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get pedigree => $composableBuilder(
      column: $table.pedigree, builder: (column) => ColumnFilters(column));
}

class $$FamilyChildrenTableOrderingComposer
    extends Composer<_$AppDatabase, $FamilyChildrenTable> {
  $$FamilyChildrenTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get familyId => $composableBuilder(
      column: $table.familyId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get treeId => $composableBuilder(
      column: $table.treeId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get personId => $composableBuilder(
      column: $table.personId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get pedigree => $composableBuilder(
      column: $table.pedigree, builder: (column) => ColumnOrderings(column));
}

class $$FamilyChildrenTableAnnotationComposer
    extends Composer<_$AppDatabase, $FamilyChildrenTable> {
  $$FamilyChildrenTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get familyId =>
      $composableBuilder(column: $table.familyId, builder: (column) => column);

  GeneratedColumn<String> get treeId =>
      $composableBuilder(column: $table.treeId, builder: (column) => column);

  GeneratedColumn<String> get personId =>
      $composableBuilder(column: $table.personId, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get pedigree =>
      $composableBuilder(column: $table.pedigree, builder: (column) => column);
}

class $$FamilyChildrenTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FamilyChildrenTable,
    FamilyChildLink,
    $$FamilyChildrenTableFilterComposer,
    $$FamilyChildrenTableOrderingComposer,
    $$FamilyChildrenTableAnnotationComposer,
    $$FamilyChildrenTableCreateCompanionBuilder,
    $$FamilyChildrenTableUpdateCompanionBuilder,
    (
      FamilyChildLink,
      BaseReferences<_$AppDatabase, $FamilyChildrenTable, FamilyChildLink>
    ),
    FamilyChildLink,
    PrefetchHooks Function()> {
  $$FamilyChildrenTableTableManager(
      _$AppDatabase db, $FamilyChildrenTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FamilyChildrenTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FamilyChildrenTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FamilyChildrenTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> familyId = const Value.absent(),
            Value<String> treeId = const Value.absent(),
            Value<String> personId = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<String> pedigree = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FamilyChildrenCompanion(
            familyId: familyId,
            treeId: treeId,
            personId: personId,
            sortOrder: sortOrder,
            pedigree: pedigree,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String familyId,
            required String treeId,
            required String personId,
            Value<int> sortOrder = const Value.absent(),
            Value<String> pedigree = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FamilyChildrenCompanion.insert(
            familyId: familyId,
            treeId: treeId,
            personId: personId,
            sortOrder: sortOrder,
            pedigree: pedigree,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$FamilyChildrenTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FamilyChildrenTable,
    FamilyChildLink,
    $$FamilyChildrenTableFilterComposer,
    $$FamilyChildrenTableOrderingComposer,
    $$FamilyChildrenTableAnnotationComposer,
    $$FamilyChildrenTableCreateCompanionBuilder,
    $$FamilyChildrenTableUpdateCompanionBuilder,
    (
      FamilyChildLink,
      BaseReferences<_$AppDatabase, $FamilyChildrenTable, FamilyChildLink>
    ),
    FamilyChildLink,
    PrefetchHooks Function()>;
typedef $$MemorialMessagesTableCreateCompanionBuilder
    = MemorialMessagesCompanion Function({
  Value<String> id,
  required String treeId,
  required String personId,
  required String authorName,
  Value<bool> isAnonymous,
  required String body,
  Value<int> likeCount,
  Value<bool> likedByMe,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$MemorialMessagesTableUpdateCompanionBuilder
    = MemorialMessagesCompanion Function({
  Value<String> id,
  Value<String> treeId,
  Value<String> personId,
  Value<String> authorName,
  Value<bool> isAnonymous,
  Value<String> body,
  Value<int> likeCount,
  Value<bool> likedByMe,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$MemorialMessagesTableFilterComposer
    extends Composer<_$AppDatabase, $MemorialMessagesTable> {
  $$MemorialMessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get treeId => $composableBuilder(
      column: $table.treeId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get personId => $composableBuilder(
      column: $table.personId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get authorName => $composableBuilder(
      column: $table.authorName, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isAnonymous => $composableBuilder(
      column: $table.isAnonymous, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get body => $composableBuilder(
      column: $table.body, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get likeCount => $composableBuilder(
      column: $table.likeCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get likedByMe => $composableBuilder(
      column: $table.likedByMe, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$MemorialMessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $MemorialMessagesTable> {
  $$MemorialMessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get treeId => $composableBuilder(
      column: $table.treeId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get personId => $composableBuilder(
      column: $table.personId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get authorName => $composableBuilder(
      column: $table.authorName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isAnonymous => $composableBuilder(
      column: $table.isAnonymous, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get body => $composableBuilder(
      column: $table.body, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get likeCount => $composableBuilder(
      column: $table.likeCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get likedByMe => $composableBuilder(
      column: $table.likedByMe, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$MemorialMessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MemorialMessagesTable> {
  $$MemorialMessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get treeId =>
      $composableBuilder(column: $table.treeId, builder: (column) => column);

  GeneratedColumn<String> get personId =>
      $composableBuilder(column: $table.personId, builder: (column) => column);

  GeneratedColumn<String> get authorName => $composableBuilder(
      column: $table.authorName, builder: (column) => column);

  GeneratedColumn<bool> get isAnonymous => $composableBuilder(
      column: $table.isAnonymous, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<int> get likeCount =>
      $composableBuilder(column: $table.likeCount, builder: (column) => column);

  GeneratedColumn<bool> get likedByMe =>
      $composableBuilder(column: $table.likedByMe, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$MemorialMessagesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MemorialMessagesTable,
    MemorialMessage,
    $$MemorialMessagesTableFilterComposer,
    $$MemorialMessagesTableOrderingComposer,
    $$MemorialMessagesTableAnnotationComposer,
    $$MemorialMessagesTableCreateCompanionBuilder,
    $$MemorialMessagesTableUpdateCompanionBuilder,
    (
      MemorialMessage,
      BaseReferences<_$AppDatabase, $MemorialMessagesTable, MemorialMessage>
    ),
    MemorialMessage,
    PrefetchHooks Function()> {
  $$MemorialMessagesTableTableManager(
      _$AppDatabase db, $MemorialMessagesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MemorialMessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MemorialMessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MemorialMessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> treeId = const Value.absent(),
            Value<String> personId = const Value.absent(),
            Value<String> authorName = const Value.absent(),
            Value<bool> isAnonymous = const Value.absent(),
            Value<String> body = const Value.absent(),
            Value<int> likeCount = const Value.absent(),
            Value<bool> likedByMe = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MemorialMessagesCompanion(
            id: id,
            treeId: treeId,
            personId: personId,
            authorName: authorName,
            isAnonymous: isAnonymous,
            body: body,
            likeCount: likeCount,
            likedByMe: likedByMe,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            Value<String> id = const Value.absent(),
            required String treeId,
            required String personId,
            required String authorName,
            Value<bool> isAnonymous = const Value.absent(),
            required String body,
            Value<int> likeCount = const Value.absent(),
            Value<bool> likedByMe = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MemorialMessagesCompanion.insert(
            id: id,
            treeId: treeId,
            personId: personId,
            authorName: authorName,
            isAnonymous: isAnonymous,
            body: body,
            likeCount: likeCount,
            likedByMe: likedByMe,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MemorialMessagesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MemorialMessagesTable,
    MemorialMessage,
    $$MemorialMessagesTableFilterComposer,
    $$MemorialMessagesTableOrderingComposer,
    $$MemorialMessagesTableAnnotationComposer,
    $$MemorialMessagesTableCreateCompanionBuilder,
    $$MemorialMessagesTableUpdateCompanionBuilder,
    (
      MemorialMessage,
      BaseReferences<_$AppDatabase, $MemorialMessagesTable, MemorialMessage>
    ),
    MemorialMessage,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TreesTableTableManager get trees =>
      $$TreesTableTableManager(_db, _db.trees);
  $$PersonsTableTableManager get persons =>
      $$PersonsTableTableManager(_db, _db.persons);
  $$FamiliesTableTableManager get families =>
      $$FamiliesTableTableManager(_db, _db.families);
  $$FamilyChildrenTableTableManager get familyChildren =>
      $$FamilyChildrenTableTableManager(_db, _db.familyChildren);
  $$MemorialMessagesTableTableManager get memorialMessages =>
      $$MemorialMessagesTableTableManager(_db, _db.memorialMessages);
}
