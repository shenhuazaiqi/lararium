import 'package:flutter_test/flutter_test.dart';
import 'package:tree/features/gedcom/gedcom.dart';

void main() {
  test('解析标准 5.5.1：人/家庭/日期/地点', () {
    const ged = '''
0 HEAD
1 CHAR UTF-8
0 @I1@ INDI
1 NAME James /Carter/
1 SEX M
1 BIRT
2 DATE 12 MAR 1918
2 PLACE Dublin, Ireland
1 DEAT
2 DATE 4 NOV 1994
1 OCCU Shipwright
1 FAMS @F1@
0 @I2@ INDI
1 NAME Mary /Carter/
1 SEX F
1 BIRT
2 DATE 1921
1 FAMS @F1@
0 @I3@ INDI
1 NAME Robert /Carter/
1 FAMC @F1@
0 @F1@ FAM
1 HUSB @I1@
1 WIFE @I2@
1 CHIL @I3@
1 MARR
2 DATE ABT 1940
0 TRLR
''';
    final r = parseGedcom(ged);
    expect(r.people.length, 3);
    expect(r.families.length, 1);
    final james = r.people['@I1@']!;
    expect(james.given, 'James');
    expect(james.surname, 'Carter');
    expect(james.gender, 'male');
    expect(james.birth!.date.year, 1918);
    expect(james.birth!.date.month, 3);
    expect(james.birth!.date.day, 12);
    expect(james.birthPlace, 'Dublin, Ireland');
    expect(james.death, isNotNull);
    expect(james.occupation, 'Shipwright');
    final fam = r.families['@F1@']!;
    expect(fam.husband, '@I1@');
    expect(fam.wife, '@I2@');
    expect(fam.children, ['@I3@']);
    expect(fam.marriage!.precision, 'approx');
  });

  test('模糊日期解析：年/月/日/约', () {
    expect(parseGedcomDate('1918')!.precision, 'year');
    expect(parseGedcomDate('MAR 1921')!.precision, 'month');
    expect(parseGedcomDate('12 MAR 1918')!.precision, 'day');
    expect(parseGedcomDate('ABT 1900')!.precision, 'approx');
    expect(parseGedcomDate('BET 1918 AND 1920')!.precision, 'year');
    expect(parseGedcomDate(''), isNull);
  });

  test('UTF-16LE BOM 解码', () {
    const text = '0 HEAD\n1 CHAR UNICODE\n';
    final bytes = <int>[0xFF, 0xFE];
    for (final cu in text.codeUnits) {
      bytes.add(cu & 0xFF);
      bytes.add((cu >> 8) & 0xFF);
    }
    expect(decodeGedcomBytes(bytes), contains('HEAD'));
  });

  test('未知标签被记录为跳过', () {
    const ged = '0 HEAD\n0 @I1@ INDI\n1 NAME A /B/\n1 _UID xyz\n1 _MILT served\n';
    final r = parseGedcom(ged);
    expect(r.skippedTags, containsAll(['__UID', '__MILT']));
  });

  test('NOTE 多行 CONT/CONC', () {
    const ged = '0 @I1@ INDI\n1 NAME A /B/\n1 NOTE line one\n2 CONT line two\n2 CONC  tail\n';
    final r = parseGedcom(ged);
    expect(r.people['@I1@']!.note, contains('line one'));
    expect(r.people['@I1@']!.note, contains('line two'));
  });
}
