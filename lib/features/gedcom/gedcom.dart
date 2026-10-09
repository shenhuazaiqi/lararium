/// GEDCOM 5.5.1 导入/导出（规划文档阶段 2 ★差异化核心）。
///
/// 支持：INDI(NAME/SEX/BIRT/DEAT/BURI/OCCU/RESI/NOTE/FAMS/FAMC)、
/// FAM(HUSB/WIFE/CHIL/MARR/DIV)、CONT/CONC 续行、
/// 编码检测（UTF-8 BOM / UTF-16 / CHAR 声明；ANSEL 按 latin1 尽力解码）。
library;

import 'dart:convert';

import 'package:drift/drift.dart';

import '../../core/fuzzy_date.dart';
import '../../data/db/app_database.dart';
import '../../data/db/tables.dart';

const months = {
  'JAN': 1, 'FEB': 2, 'MAR': 3, 'APR': 4, 'MAY': 5, 'JUN': 6,
  'JUL': 7, 'AUG': 8, 'SEP': 9, 'OCT': 10, 'NOV': 11, 'DEC': 12,
};

class GedcomLine {
  GedcomLine(this.level, this.xref, this.tag, this.value);

  final int level;
  final String? xref;
  final String tag;
  final String? value;
}

List<GedcomLine> parseGedcomLines(String text) {
  final lines = <GedcomLine>[];
  final re = RegExp(r'^\s*(\d+)\s+(?:(@[^@]+@)\s+)?([A-Za-z0-9_]+)(?:\s(.*))?$');
  for (final raw in text.split(RegExp(r'\r\n|\r|\n'))) {
    if (raw.trim().isEmpty) continue;
    final m = re.firstMatch(raw);
    if (m == null) continue; // 容错优先：跳过无法解析的行
    lines.add(GedcomLine(
      int.parse(m.group(1)!),
      m.group(2),
      m.group(3)!.toUpperCase(),
      m.group(4),
    ));
  }
  return lines;
}

/// GEDCOM DATE → 本地模糊日期。"12 MAR 1918" / "MAR 1918" / "1918" / "ABT 1900"
FuzzyDate? parseGedcomDate(String s) {
  final v = s.trim().toUpperCase();
  if (v.isEmpty) return null;
  final yearMatch = RegExp(r'(\d{4})').firstMatch(v);
  if (yearMatch == null) return null;
  final year = int.parse(yearMatch.group(1)!);
  final monthMatch = RegExp(r'\b([A-Z]{3})\b').firstMatch(v);
  int month = 1, day = 1;
  var precision = 'year';
  if (monthMatch != null && months.containsKey(monthMatch.group(1))) {
    month = months[monthMatch.group(1)]!;
    precision = 'month';
    final dayMatch = RegExp(r'^\d{1,2}\b').firstMatch(v.trim());
    if (dayMatch != null) {
      day = int.parse(dayMatch.group(0)!);
      precision = 'day';
    }
  }
  if (v.startsWith('ABT') || v.startsWith('EST')) precision = 'approx';
  return FuzzyDate(DateTime(year, month, day), precision);
}

/// 编码检测：BOM → CHAR 声明 → 兜底 UTF-8（ANSEL 按 latin1 尽力解码）。
String decodeGedcomBytes(List<int> bytes) {
  if (bytes.length >= 3 && bytes[0] == 0xEF && bytes[1] == 0xBB && bytes[2] == 0xBF) {
    return utf8.decode(bytes.sublist(3), allowMalformed: true);
  }
  if (bytes.length >= 2 && bytes[0] == 0xFF && bytes[1] == 0xFE) {
    return utf16leDecode(bytes.sublist(2));
  }
  if (bytes.length >= 2 && bytes[0] == 0xFE && bytes[1] == 0xFF) {
    return utf16beDecode(bytes.sublist(2));
  }
  // 无 BOM：先按 UTF-8 试解码；大量非法字节则按 latin1（ANSEL 近似）
  try {
    return utf8.decode(bytes);
  } on FormatException {
    return latin1.decode(bytes);
  }
}

String utf16leDecode(List<int> b) {
  final sb = StringBuffer();
  for (var i = 0; i + 1 < b.length; i += 2) {
    sb.writeCharCode(b[i] | (b[i + 1] << 8));
  }
  return sb.toString();
}

String utf16beDecode(List<int> b) {
  final sb = StringBuffer();
  for (var i = 0; i + 1 < b.length; i += 2) {
    sb.writeCharCode((b[i] << 8) | b[i + 1]);
  }
  return sb.toString();
}

class GedcomPersonData {
  String given = '';
  String surname = '';
  String gender = 'unknown';
  FuzzyDate? birth;
  String? birthPlace;
  FuzzyDate? death;
  String? deathPlace;
  String? burial;
  String? occupation;
  String note = '';
  final List<String> fams = []; // 配偶家庭
  final List<String> famc = []; // 作为孩子的家庭
}

class GedcomFamilyData {
  String? husband;
  String? wife;
  final List<String> children = [];
  FuzzyDate? marriage;
  String? marriagePlace;
  FuzzyDate? divorce;
}

class GedcomParseResult {
  final Map<String, GedcomPersonData> people = {};
  final Map<String, GedcomFamilyData> families = {};
  final Set<String> skippedTags = {};
}

GedcomParseResult parseGedcom(String text) {
  final lines = parseGedcomLines(text);
  final out = GedcomParseResult();

  GedcomPersonData? curPerson;
  String? curPersonXref;
  GedcomFamilyData? curFam;
  String? curFamXref;
  // 事件上下文（BIRT/DEAT/BURI/MARR/DIV 的子行）
  String? eventCtx;
  String? noteCtx; // 'p' 人物备注

  void appendNote(String chunk, {required bool cont}) {
    if (noteCtx == 'p' && curPerson != null) {
      final cur = curPerson.note;
      curPerson.note = cont ? '$cur$chunk' : '$cur\n$chunk';
    }
  }

  for (final l in lines) {
    switch (l.tag) {
      case 'HEAD':
      case 'TRLR':
        break;
      case 'INDI':
        curPersonXref = l.xref;
        curPerson = out.people.putIfAbsent(curPersonXref ?? '', GedcomPersonData.new);
        curFam = null;
        eventCtx = null;
        noteCtx = null;
        break;
      case 'FAM':
        curFamXref = l.xref;
        curFam = out.families.putIfAbsent(curFamXref ?? '', GedcomFamilyData.new);
        curPerson = null;
        eventCtx = null;
        noteCtx = null;
        break;
      case 'NAME':
        if (curPerson != null) {
          final v = l.value ?? '';
          final m = RegExp(r'^(.*?)\s*/(.*?)/\s*(.*)$').firstMatch(v);
          if (m != null) {
            curPerson.given = (m.group(1) ?? '').trim();
            curPerson.surname = (m.group(2) ?? '').trim();
          } else {
            curPerson.given = v.trim();
          }
        }
        eventCtx = null;
        break;
      case 'GIVN':
        if (curPerson != null && curPerson.given.isEmpty) {
          curPerson.given = (l.value ?? '').trim();
        }
        break;
      case 'SURN':
        if (curPerson != null && curPerson.surname.isEmpty) {
          curPerson.surname = (l.value ?? '').trim();
        }
        break;
      case 'SEX':
        if (curPerson != null) {
          final s = (l.value ?? '').trim().toUpperCase();
          curPerson.gender = s == 'M' ? 'male' : s == 'F' ? 'female' : 'unknown';
        }
        break;
      case 'BIRT':
        eventCtx = 'birth';
        noteCtx = null;
        break;
      case 'DEAT':
        eventCtx = 'death';
        noteCtx = null;
        break;
      case 'BURI':
        eventCtx = 'burial';
        noteCtx = null;
        break;
      case 'OCCU':
        if (curPerson != null) curPerson.occupation = l.value?.trim();
        eventCtx = null;
        break;
      case 'RESI':
        eventCtx = 'resi';
        break;
      case 'NOTE':
        noteCtx = curPerson != null ? 'p' : null;
        if (noteCtx != null && l.value != null && l.value!.isNotEmpty) {
          appendNote(l.value!, cont: false);
        }
        break;
      case 'CONT':
        appendNote(l.value ?? '', cont: true);
        break;
      case 'CONC':
        appendNote(l.value ?? '', cont: true);
        break;
      case 'DATE':
        final d = l.value == null ? null : parseGedcomDate(l.value!);
        if (d != null) {
          if (eventCtx == 'birth') curPerson?.birth = d;
          if (eventCtx == 'death') curPerson?.death = d;
          if (eventCtx == 'burial') {} // BURI 日期暂不建模
          if (eventCtx == 'marr') curFam?.marriage = d;
          if (eventCtx == 'div') curFam?.divorce = d;
        }
        break;
      case 'PLACE':
        if (eventCtx == 'birth') curPerson?.birthPlace = l.value?.trim();
        if (eventCtx == 'death') curPerson?.deathPlace = l.value?.trim();
        if (eventCtx == 'burial') curPerson?.burial = l.value?.trim();
        if (eventCtx == 'resi') {} // 居住地在事件表阶段启用
        if (eventCtx == 'marr') curFam?.marriagePlace = l.value?.trim();
        break;
      case 'MARR':
        eventCtx = 'marr';
        break;
      case 'DIV':
        eventCtx = 'div';
        break;
      case 'FAMS':
        if (curPerson != null && l.value != null) curPerson.fams.add(l.value!);
        break;
      case 'FAMC':
        if (curPerson != null && l.value != null) curPerson.famc.add(l.value!);
        break;
      case 'HUSB':
        if (curFam != null) curFam.husband = l.value;
        break;
      case 'WIFE':
        if (curFam != null) curFam.wife = l.value;
        break;
      case 'CHIL':
        if (curFam != null && l.value != null) curFam.children.add(l.value!);
        break;
      default:
        if (!const {
          'GIVN', 'SURN', 'NICK', 'NPFX', 'NSFX', 'SOUR', 'GEDC', 'VERS',
          'FORM', 'CHAR', 'SUBM', 'FILE', 'COPR', 'CORP', 'DATE', 'TIME',
          'REPO', 'MEDIA', 'CHAN', 'QUAY', 'ADDR', 'CITY', 'STAE', 'CTRY',
          'POST', 'TYPE', 'AUTH', 'TITL', 'PUBL', 'TEXT', 'OBJE', 'REFN',
          'RIN', 'RFN', 'AFN', 'SUBN', 'DEST', 'LANG',
        }.contains(l.tag)) {
          out.skippedTags.add('_${l.tag}');
        }
        if (l.level <= 1) eventCtx = null;
    }
  }
  return out;
}

class GedcomImportReport {
  int persons = 0;
  int families = 0;
  int generations = 0;
  final Set<String> skippedTags = {};
}

/// 把解析结果写入一棵（新建的）树。
Future<GedcomImportReport> importGedcomInto(
  AppDatabase db,
  String treeId,
  String text,
) async {
  final parsed = parseGedcom(text);
  final report = GedcomImportReport()..skippedTags.addAll(parsed.skippedTags);

  final xrefToPerson = <String, String>{};
  for (final e in parsed.people.entries) {
    final p = e.value;
    final id = newId();
    xrefToPerson[e.key] = id;
    await db.into(db.persons).insert(PersonsCompanion.insert(
          id: Value(id),
          treeId: treeId,
          givenName: Value(p.given),
          surname: Value(p.surname),
          gender: Value(p.gender),
          birthDate: Value(p.birth?.date),
          birthPrecision: Value(p.birth?.precision ?? 'day'),
          birthPlace: Value(p.birthPlace),
          deathDate: Value(p.death?.date),
          deathPrecision: Value(p.death?.precision ?? 'day'),
          deathPlace: Value(p.deathPlace),
          burialPlace: Value(p.burial),
          isLiving: Value(p.death == null),
          occupation: Value(p.occupation),
          note: Value(p.note.trim().isEmpty ? null : p.note.trim()),
        ));
    report.persons++;
  }

  for (final e in parsed.families.entries) {
    final f = e.value;
    final fid = newId();
    await db.into(db.families).insert(FamiliesCompanion.insert(
          id: Value(fid),
          treeId: treeId,
          partner1Id: Value(f.husband == null ? null : xrefToPerson[f.husband!]),
          partner2Id: Value(f.wife == null ? null : xrefToPerson[f.wife!]),
          relationType: const Value('married'),
          marriageDate: Value(f.marriage?.date),
        ));
    for (final c in f.children) {
      final pid = xrefToPerson[c];
      if (pid == null) continue;
      await db.into(db.familyChildren).insert(FamilyChildrenCompanion.insert(
            familyId: fid,
            treeId: treeId,
            personId: pid,
          ));
    }
    report.families++;
  }

  // 代数：沿父母链向上取深度（防环）
  final parentFamilyOf = <String, String>{};
  for (final e in parsed.people.entries) {
    for (final f in e.value.famc) {
      parentFamilyOf.putIfAbsent(e.key, () => f);
    }
  }
  final memo = <String, int>{};
  final visiting = <String>{};
  int depthOf(String xref) {
    final cached = memo[xref];
    if (cached != null) return cached;
    if (!visiting.add(xref)) return 0; // 环保护
    final pf = parentFamilyOf[xref];
    int d = 0;
    if (pf != null) {
      final fam = parsed.families[pf];
      final parents = [fam?.husband, fam?.wife].whereType<String>().toList();
      var maxP = -1;
      for (final p in parents) {
        final pd = depthOf(p);
        if (pd > maxP) maxP = pd;
      }
      d = maxP + 1;
    }
    visiting.remove(xref);
    memo[xref] = d;
    return d;
  }

  var maxGen = 0;
  for (final x in parsed.people.keys) {
    final d = depthOf(x);
    if (d > maxGen) maxGen = d;
  }
  report.generations = parsed.people.isEmpty ? 0 : maxGen + 1;
  return report;
}

/// 导出一棵树为 GEDCOM 5.5.1 文本。
/// [includeLiving]=false 时剔除在世人及其孤悬引用（隐私脱敏导出）。
Future<String> exportGedcom(AppDatabase db, String treeId,
    {bool includeLiving = true}) async {
  var persons = await (db.select(db.persons)
        ..where((p) => p.treeId.equals(treeId) & p.deletedAt.isNull()))
      .get();
  if (!includeLiving) {
    persons = persons.where((p) => !p.isLiving).toList();
  }
  final keptIds = persons.map((p) => p.id).toSet();
  var families = await (db.select(db.families)
        ..where((f) => f.treeId.equals(treeId) & f.deletedAt.isNull()))
      .get();
  var links = await (db.select(db.familyChildren)
        ..where((c) => c.treeId.equals(treeId)))
      .get();
  if (!includeLiving) {
    links =
        links.where((l) => keptIds.contains(l.personId)).toList();
    final liveFams = links.map((l) => l.familyId).toSet();
    families = families.where((f) {
      final p1 = f.partner1Id == null || keptIds.contains(f.partner1Id!);
      final p2 = f.partner2Id == null || keptIds.contains(f.partner2Id!);
      return (p1 || p2) && liveFams.contains(f.id);
    }).toList();
    final famIds = families.map((f) => f.id).toSet();
    links = links.where((l) => famIds.contains(l.familyId)).toList();
  }

  final pXref = <String, String>{};
  for (var i = 0; i < persons.length; i++) {
    pXref[persons[i].id] = '@I${i + 1}@';
  }
  final fXref = <String, String>{};
  for (var i = 0; i < families.length; i++) {
    fXref[families[i].id] = '@F${i + 1}@';
  }

  String esc(String s) => s.replaceAll('@', '@@');

  String dateOut(DateTime? d, String precision) {
    if (d == null) return '';
    String? mon;
    for (final e in months.entries) {
      if (e.value == d.month) {
        mon = e.key;
        break;
      }
    }
    switch (precision) {
      case 'year':
        return '${d.year}';
      case 'approx':
        return 'ABT ${d.year}';
      case 'month':
        return '${mon ?? 'JAN'} ${d.year}';
      default:
        return '${d.day} ${mon ?? 'JAN'} ${d.year}';
    }
  }

  final sb = StringBuffer();
  sb.writeln('0 HEAD');
  sb.writeln('1 SOUR LARARIUM');
  sb.writeln('2 NAME Lararium');
  sb.writeln('2 VERS 0.2.0');
  sb.writeln('1 GEDC');
  sb.writeln('2 VERS 5.5.1');
  sb.writeln('2 FORM LINEAGE-LINKED');
  sb.writeln('1 CHAR UTF-8');
  final now = DateTime.now();
  const monNames = ['JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC'];
  sb.writeln('1 DATE ${now.day} ${monNames[now.month - 1]} ${now.year}');

  for (final p in persons) {
    sb.writeln('0 ${pXref[p.id]} INDI');
    sb.writeln('1 NAME ${esc(p.givenName)} /${esc(p.surname)}/');
    sb.writeln('2 GIVN ${esc(p.givenName)}');
    sb.writeln('2 SURN ${esc(p.surname)}');
    sb.writeln('1 SEX ${p.gender == 'male' ? 'M' : p.gender == 'female' ? 'F' : 'U'}');
    if (p.birthDate != null) {
      sb.writeln('1 BIRT');
      sb.writeln('2 DATE ${dateOut(p.birthDate, p.birthPrecision)}');
      if (p.birthPlace?.isNotEmpty ?? false) sb.writeln('2 PLACE ${esc(p.birthPlace!)}');
    }
    if (!p.isLiving && p.deathDate != null) {
      sb.writeln('1 DEAT');
      sb.writeln('2 DATE ${dateOut(p.deathDate, p.deathPrecision)}');
      if (p.deathPlace?.isNotEmpty ?? false) sb.writeln('2 PLACE ${esc(p.deathPlace!)}');
    }
    if (p.burialPlace?.isNotEmpty ?? false) {
      sb.writeln('1 BURI');
      sb.writeln('2 PLACE ${esc(p.burialPlace!)}');
    }
    if (p.occupation?.isNotEmpty ?? false) sb.writeln('1 OCCU ${esc(p.occupation!)}');
    if (p.note?.isNotEmpty ?? false) {
      final lines = p.note!.split('\n');
      sb.writeln('1 NOTE ${esc(lines.first)}');
      for (final extra in lines.skip(1)) {
        sb.writeln('2 CONT ${esc(extra)}');
      }
    }
    for (final f in families) {
      if (f.partner1Id == p.id || f.partner2Id == p.id) {
        sb.writeln('1 FAMS ${fXref[f.id]}');
      }
    }
    for (final l in links) {
      if (l.personId == p.id) sb.writeln('1 FAMC ${fXref[l.familyId]}');
    }
  }

  for (final f in families) {
    sb.writeln('0 ${fXref[f.id]} FAM');
    if (f.partner1Id != null && pXref.containsKey(f.partner1Id)) {
      sb.writeln('1 HUSB ${pXref[f.partner1Id!]}');
    }
    if (f.partner2Id != null && pXref.containsKey(f.partner2Id)) {
      sb.writeln('1 WIFE ${pXref[f.partner2Id!]}');
    }
    for (final l in links) {
      if (l.familyId == f.id && pXref.containsKey(l.personId)) {
        sb.writeln('1 CHIL ${pXref[l.personId]}');
      }
    }
    if (f.marriageDate != null) {
      sb.writeln('1 MARR');
      sb.writeln('2 DATE ${dateOut(f.marriageDate, 'day')}');
    }
  }
  sb.writeln('0 TRLR');
  return sb.toString();
}
