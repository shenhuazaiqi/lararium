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

  Future<int> countPeople(String treeId) async {
    final rows = await (_db.select(_db.persons)
          ..where((p) => p.treeId.equals(treeId) & p.deletedAt.isNull()))
        .get();
    return rows.length;
  }

}
