import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../../core/capture.dart';
import '../../data/db/app_database.dart';
import '../../data/db/tables.dart' show newId;
import '../gedcom/gedcom.dart';

enum ExportFormat { pdf, png, gedcom, json }

class ExportResult {
  ExportResult(this.path, this.fileName);

  final String path;
  final String fileName;
}

/// 导出中心（规划文档阶段 2）：PDF 海报 / PNG 高清图 / GEDCOM / JSON 全量备份。
class ExportService {
  ExportService(this._db);

  final AppDatabase _db;

  Future<File> _writeTemp(String fileName, List<int> bytes) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  Future<ExportResult> exportGedcomFile(String treeId,
      {required bool includeLiving}) async {
    final text =
        await exportGedcom(_db, treeId, includeLiving: includeLiving);
    final f = await _writeTemp('lararium_export.ged', utf8.encode(text));
    return ExportResult(f.path, 'lararium_export.ged');
  }

  Future<ExportResult> exportJsonBackup(String treeId) async {
    final persons = await (_db.select(_db.persons)
          ..where((p) => p.treeId.equals(treeId) & p.deletedAt.isNull()))
        .get();
    final families = await (_db.select(_db.families)
          ..where((f) => f.treeId.equals(treeId) & f.deletedAt.isNull()))
        .get();
    final links = await (_db.select(_db.familyChildren)
          ..where((c) => c.treeId.equals(treeId)))
        .get();
    final msgs = await (_db.select(_db.memorialMessages)
          ..where((m) => m.treeId.equals(treeId)))
        .get();
    final tree = await (_db.select(_db.trees)..where((t) => t.id.equals(treeId)))
        .getSingleOrNull();

    final data = {
      'format': 'lararium-backup',
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'tree': tree == null
          ? null
          : {
              'name': tree.name,
              'description': tree.description,
              'createdAt': tree.createdAt.toIso8601String(),
            },
      'persons': [
        for (final p in persons)
          {
            'id': p.id,
            'givenName': p.givenName,
            'surname': p.surname,
            'gender': p.gender,
            'birthDate': p.birthDate?.toIso8601String(),
            'birthPrecision': p.birthPrecision,
            'birthPlace': p.birthPlace,
            'deathDate': p.deathDate?.toIso8601String(),
            'deathPrecision': p.deathPrecision,
            'deathPlace': p.deathPlace,
            'burialPlace': p.burialPlace,
            'isLiving': p.isLiving,
            'occupation': p.occupation,
            'note': p.note,
            'memorialTheme': p.memorialTheme,
            'epitaph': p.epitaph,
            'isSelf': p.isSelf,
          },
      ],
      'families': [
        for (final f in families)
          {
            'id': f.id,
            'partner1Id': f.partner1Id,
            'partner2Id': f.partner2Id,
            'relationType': f.relationType,
            'marriageDate': f.marriageDate?.toIso8601String(),
          },
      ],
      'familyChildren': [
        for (final l in links)
          {'familyId': l.familyId, 'personId': l.personId, 'sortOrder': l.sortOrder},
      ],
      'memorialMessages': [
        for (final m in msgs)
          {
            'personId': m.personId,
            'authorName': m.authorName,
            'body': m.body,
            'createdAt': m.createdAt.toIso8601String(),
          },
      ],
    };
    final f = await _writeTemp(
        'lararium_backup.json', utf8.encode(const JsonEncoder.withIndent('  ').convert(data)));
    return ExportResult(f.path, 'lararium_backup.json');
  }

  /// PNG：直接截取树画布（系统字体渲染，CJK 安全）。
  Future<ExportResult?> exportPng(String treeName) async {
    final bytes = await captureTreePng();
    if (bytes == null) return null;
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final f = await _writeTemp('lararium_tree_$stamp.png', bytes);
    return ExportResult(f.path, 'lararium_tree_$stamp.png');
  }

  /// PDF 海报：树图 PNG 嵌入 + 标题页脚（A4 / 2× 海报）。
  /// 名字以图像渲染（系统字体 → CJK 安全）；页面文字用 pdf 内置字体。
  Future<ExportResult?> exportPdf(String treeName,
      {required bool poster2x, required Uint8List? treePng}) async {
    if (treePng == null) return null;
    final doc = pw.Document();
    final format =
        poster2x ? PdfPageFormat.a3 : PdfPageFormat.a4;
    final image = pw.MemoryImage(treePng);
    doc.addPage(
      pw.Page(
        pageFormat: format,
        margin: const pw.EdgeInsets.all(28),
        build: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(treeName,
                style: pw.TextStyle(
                    fontSize: poster2x ? 30 : 22,
                    fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 4),
            pw.Text('Lararium - Family Tree  ·  ${_todayLabel()}',
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
            pw.SizedBox(height: 12),
            pw.Expanded(
              child: pw.Center(
                child: pw.Image(image, fit: pw.BoxFit.contain),
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Text('The shrine your family keeps.',
                style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
              ),
          ],
        ),
      ),
    );
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final f = await _writeTemp(
        'lararium_tree_$stamp.pdf', await doc.save());
    return ExportResult(f.path, 'lararium_tree_$stamp.pdf');
  }

  String _todayLabel() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }

  Future<void> share(ExportResult r) async {
    await Share.shareXFiles([XFile(r.path)], text: 'Lararium · ${r.fileName}');
  }

  /// 从 JSON 备份恢复为一棵**新树**（规划文档 5.2「自家 JSON 备份」的另一半）。
  /// 人物/家庭 id 全部重映射，避免与现有数据主键冲突。
  Future<String> restoreJsonBackup(String jsonText, {String? newName}) async {
    final data = jsonDecode(jsonText) as Map<String, dynamic>;
    if (data['format'] != 'lararium-backup') {
      throw const FormatException('not a lararium backup');
    }
    final treeId = newId();
    final srcTree = data['tree'] as Map<String, dynamic>?;
    await (_db.into(_db.trees)).insert(TreesCompanion.insert(
      id: Value(treeId),
      name: newName ?? (((srcTree?['name'] as String?) ?? 'Restored') + ' (restored)'),
      description: Value(srcTree?['description'] as String?),
    ));

    final idMap = <String, String>{};
    for (final raw in (data['persons'] as List? ?? [])) {
      final p = raw as Map<String, dynamic>;
      final oldId = p['id'] as String;
      final nid = newId();
      idMap[oldId] = nid;
      await _db.into(_db.persons).insert(PersonsCompanion.insert(
            id: Value(nid),
            treeId: treeId,
            givenName: Value(p['givenName'] as String? ?? ''),
            surname: Value(p['surname'] as String? ?? ''),
            gender: Value(p['gender'] as String? ?? 'unknown'),
            birthDate: Value(_tryDate(p['birthDate'] as String?)),
            birthPrecision: Value(p['birthPrecision'] as String? ?? 'day'),
            birthPlace: Value(p['birthPlace'] as String?),
            deathDate: Value(_tryDate(p['deathDate'] as String?)),
            deathPrecision: Value(p['deathPrecision'] as String? ?? 'day'),
            deathPlace: Value(p['deathPlace'] as String?),
            burialPlace: Value(p['burialPlace'] as String?),
            isLiving: Value(p['isLiving'] as bool? ?? true),
            occupation: Value(p['occupation'] as String?),
            note: Value(p['note'] as String?),
            memorialTheme: Value(p['memorialTheme'] as String?),
            epitaph: Value(p['epitaph'] as String?),
            isSelf: Value(p['isSelf'] as bool? ?? false),
          ));
    }
    for (final raw in (data['families'] as List? ?? [])) {
      final f = raw as Map<String, dynamic>;
      await _db.into(_db.families).insert(FamiliesCompanion.insert(
            id: Value(newId()),
            treeId: treeId,
            partner1Id:
                Value(f['partner1Id'] == null ? null : idMap[f['partner1Id'] as String]),
            partner2Id:
                Value(f['partner2Id'] == null ? null : idMap[f['partner2Id'] as String]),
            relationType: Value(f['relationType'] as String? ?? 'married'),
            marriageDate: Value(_tryDate(f['marriageDate'] as String?)),
          ));
    }
    for (final raw in (data['familyChildren'] as List? ?? [])) {
      final l = raw as Map<String, dynamic>;
      final fid = idMap[l['familyId'] as String? ?? ''];
      final pid = idMap[l['personId'] as String? ?? ''];
      if (fid == null || pid == null) continue;
      await _db.into(_db.familyChildren).insert(FamilyChildrenCompanion.insert(
            familyId: fid,
            treeId: treeId,
            personId: pid,
          ));
    }
    for (final raw in (data['memorialMessages'] as List? ?? [])) {
      final m = raw as Map<String, dynamic>;
      final pid = idMap[m['personId'] as String? ?? ''];
      if (pid == null) continue;
      await _db.into(_db.memorialMessages).insert(MemorialMessagesCompanion.insert(
            treeId: treeId,
            personId: pid,
            authorName: m['authorName'] as String? ?? '',
            body: m['body'] as String? ?? '',
          ));
    }
    return treeId;
  }

  DateTime? _tryDate(String? s) => s == null ? null : DateTime.tryParse(s);

  Future<int> countPeople(String treeId) async {
    final rows = await (_db.select(_db.persons)
          ..where((p) => p.treeId.equals(treeId) & p.deletedAt.isNull()))
        .get();
    return rows.length;
  }

}
