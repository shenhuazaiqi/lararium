import 'package:drift/drift.dart' show Value;

import '../db/app_database.dart';
import '../db/tables.dart';

/// 首次启动的示例家谱（对标原型 Carter Family，10 人 3 代）。
/// 新用户 30 秒上手的引导数据；用户可整树删除。规划文档阶段 6「示例家谱」。
class DemoSeed {
  DemoSeed(this._db);

  final AppDatabase _db;

  Future<String> seed() async {
    final treeId = newId();
    await _db.into(_db.trees).insert(TreesCompanion.insert(
          id: Value(treeId),
          name: 'Carter Family',
          description: const Value('Demo family — tap around, then make it yours.'),
          isDemo: const Value(true),
        ));

    String p({
      required String given,
      required String surname,
      String gender = 'unknown',
      DateTime? birth,
      String birthPrecision = 'day',
      String? birthPlace,
      DateTime? death,
      String? deathPlace,
      String? burial,
      String? occupation,
      bool isSelf = false,
      String? theme,
      String? epitaph,
      int flowers = 0,
      int candles = 0,
      int incense = 0,
      int prayers = 0,
      int messages = 0,
    }) {
      final id = newId();
      _ids[given] = id;
      _pending.add(PersonsCompanion.insert(
        id: Value(id),
        treeId: treeId,
        givenName: Value(given),
        surname: Value(surname),
        gender: Value(gender),
        birthDate: Value(birth),
        birthPrecision: Value(birthPrecision),
        birthPlace: Value(birthPlace),
        deathDate: Value(death),
        deathPlace: Value(deathPlace),
        burialPlace: Value(burial),
        occupation: Value(occupation),
        isLiving: Value(death == null),
        isSelf: Value(isSelf),
        memorialTheme: Value(theme),
        epitaph: Value(epitaph),
        flowerCount: Value(flowers),
        candleCount: Value(candles),
        incenseCount: Value(incense),
        prayerCount: Value(prayers),
        messageCount: Value(messages),
      ));
      return id;
    }

    DateTime d(String s) => DateTime.parse(s.length > 7 ? s : '$s-01-01');

    p(
        given: 'James',
        surname: 'Carter',
        gender: 'male',
        birth: d('1918-03-12'),
        birthPlace: 'Dublin, Ireland',
        death: d('1994-11-04'),
        deathPlace: 'Boston, MA',
        burial: 'Oakwood Cemetery',
        occupation: 'Shipwright',
        theme: 'western',
        epitaph: 'A quiet man with a loud laugh. He never missed a Sunday.',
        flowers: 32,
        candles: 18,
        incense: 7,
        prayers: 11,
        messages: 3);
    p(
        given: 'Mary',
        surname: 'Carter',
        gender: 'female',
        birth: d('1921-06-02'),
        birthPlace: 'Cork, Ireland',
        death: d('2003-03-30'),
        deathPlace: 'Boston, MA',
        burial: 'Oakwood Cemetery',
        occupation: 'Baker',
        theme: 'western',
        epitaph: 'Her kitchen smelled like bread every Saturday morning.',
        flowers: 41,
        candles: 26,
        incense: 12,
        prayers: 14,
        messages: 2);
    p(
        given: 'Robert',
        surname: 'Carter',
        gender: 'male',
        birth: d('1948-04-09'),
        birthPlace: 'Boston, MA',
        occupation: 'Architect');
    p(
        given: 'Linda',
        surname: 'Carter',
        gender: 'female',
        birth: d('1951-11-21'),
        birthPlace: 'Providence, RI',
        occupation: 'Nurse');
    p(
        given: 'William',
        surname: 'Carter',
        gender: 'male',
        birth: d('1954-01-30'),
        birthPlace: 'Boston, MA',
        death: d('2011-08-19'),
        deathPlace: 'Denver, CO',
        burial: 'Fairmount Cemetery',
        occupation: 'Mechanic',
        theme: 'western',
        epitaph: 'Taught me to fish — and to be quiet while doing it.',
        flowers: 11,
        candles: 7,
        incense: 5,
        prayers: 4,
        messages: 1);
    p(
        given: 'Sarah',
        surname: 'Miller',
        gender: 'female',
        birth: d('1979-07-14'),
        birthPlace: 'Boston, MA',
        occupation: 'Teacher');
    p(
        given: 'Michael',
        surname: 'Carter',
        gender: 'male',
        birth: d('1976-02-03'),
        birthPlace: 'Boston, MA',
        occupation: 'Architect',
        isSelf: true);
    p(
        given: 'Emma',
        surname: 'Carter',
        gender: 'female',
        birth: d('1978-09-18'),
        birthPlace: 'Chicago, IL',
        occupation: 'Designer');
    p(
        given: 'Noah',
        surname: 'Carter',
        gender: 'male',
        birth: d('2005-05-06'),
        birthPlace: 'Portland, OR',
        occupation: 'Student');
    p(
        given: 'Ava',
        surname: 'Carter',
        gender: 'female',
        birth: d('2009-12-11'),
        birthPlace: 'Portland, OR',
        occupation: 'Student');

    for (final companion in _pending) {
      await _db.into(_db.persons).insert(companion);
    }
    _pending.clear();

    Future<String> fam(String? p1, String? p2, List<String> children) async {
      final fid = newId();
      await _db.into(_db.families).insert(FamiliesCompanion.insert(
            id: Value(fid),
            treeId: treeId,
            partner1Id: Value(p1),
            partner2Id: Value(p2),
          ));
      for (final c in children) {
        await _db.into(_db.familyChildren).insert(FamilyChildrenCompanion.insert(
              familyId: fid,
              treeId: treeId,
              personId: c,
            ));
      }
      return fid;
    }

    await fam(_ids['James'], _ids['Mary'], [_ids['Robert']!, _ids['William']!]);
    await fam(_ids['Robert'], _ids['Linda'], [_ids['Sarah']!, _ids['Michael']!]);
    await fam(_ids['Michael'], _ids['Emma'], [_ids['Noah']!, _ids['Ava']!]);

    Future<void> msg(String person, String who, String body, int likes,
        bool mine) async {
      await _db.into(_db.memorialMessages).insert(MemorialMessagesCompanion.insert(
            treeId: treeId,
            personId: _ids[person]!,
            authorName: who,
            body: body,
            likeCount: Value(likes),
            likedByMe: Value(mine),
          ));
    }

    await msg('James', 'Emma Carter',
        'Thinking of Grandpa today. He would have loved to see Noah graduate.', 12, false);
    await msg('James', 'Robert Carter',
        'Lit a candle for Dad. Still miss our Sunday walks.', 9, true);
    await msg('James', 'Sarah Miller',
        'Grandma’s recipe book is still in my kitchen. Every Sunday.', 7, false);
    await msg('Mary', 'Michael Carter',
        'Made her bread recipe this morning. It finally tasted right.', 15, true);
    await msg('Mary', 'Sarah Miller',
        'She kept every birthday card I ever made. Every single one.', 11, false);
    await msg('William', 'Robert Carter',
        'Taught me to fish, and to be quiet while doing it. Miss you, Bill.', 6, true);

    return treeId;
  }

  final Map<String, String> _ids = {};
  final List<PersonsCompanion> _pending = [];
}
