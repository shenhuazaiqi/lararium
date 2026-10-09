import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../data/db/app_database.dart';
import '../../data/providers.dart';
import '../gedcom/gedcom.dart';

/// 13 GEDCOM 导入：本机解析（不上传）→ 建新树 → 结果报告。
class ImportScreen extends ConsumerStatefulWidget {
  const ImportScreen({super.key});

  @override
  ConsumerState<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends ConsumerState<ImportScreen> {
  bool _busy = false;
  GedcomImportReport? _report;
  String? _importedTreeId;
  String? _fileName;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<LarariumColors>()!;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        title: Text(l10n.importTitle,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 30),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colors.surface2,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.line2, width: 1.5),
            ),
            child: Column(
              children: [
                Icon(Icons.upload_file_outlined, size: 40, color: colors.ink3),
                const SizedBox(height: 12),
                Text(l10n.impPick,
                    style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w600,
                        color: colors.ink)),
                const SizedBox(height: 6),
                Text(l10n.impNote,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12.5, color: colors.ink3)),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.brand,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: _busy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.file_open_outlined, size: 18),
                    label: Text(l10n.impGo),
                    onPressed: _busy ? null : _pickAndImport,
                  ),
                ),
              ],
            ),
          ),
          if (_fileName != null) ...[
            const SizedBox(height: 14),
            Center(
              child: Text(_fileName!,
                  style: TextStyle(fontSize: 12, color: colors.ink4)),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colors.dangerSoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(_error!,
                  style: TextStyle(fontSize: 13.5, color: colors.danger)),
            ),
          ],
          if (_report != null) ...[
            const SizedBox(height: 18),
            Text(l10n.impResult.toUpperCase(),
                style: TextStyle(
                    fontSize: 12.5,
                    letterSpacing: 0.6,
                    fontWeight: FontWeight.w700,
                    color: colors.ink3)),
            const SizedBox(height: 9),
            _row(colors, Icons.check_circle_outline, colors.brand,
                l10n.impPeople(_report!.persons)),
            Divider(color: colors.line, height: 1),
            _row(colors, Icons.check_circle_outline, colors.brand,
                l10n.impFamilies(_report!.families, _report!.generations)),
            Divider(color: colors.line, height: 1),
            _row(
                colors,
                Icons.info_outline,
                colors.amber,
                l10n.impSkippedTags(_report!.skippedTags.length)),
            const SizedBox(height: 20),
            SizedBox(
              height: 50,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: colors.brand,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _importedTreeId == null
                    ? null
                    : () {
                        ref
                            .read(currentTreeIdProvider.notifier)
                            .state = _importedTreeId;
                        ref.read(prefsProvider).setString(
                            'current_tree_id', _importedTreeId!);
                        context.go('/tree');
                      },
                child: Text(l10n.impOpenTree,
                    style: const TextStyle(
                        fontSize: 15.5, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _row(LarariumColors colors, IconData icon, Color color, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 11),
          Expanded(
            child: Text(text,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: colors.ink)),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndImport() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _error = null;
      _report = null;
      _importedTreeId = null;
    });
    try {
      final picked = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['ged', 'gedcom', 'txt'],
        withData: true,
      );
      if (picked == null || picked.files.isEmpty) {
        setState(() => _busy = false);
        return;
      }
      final file = picked.files.single;
      final String text;
      if (file.bytes != null) {
        text = decodeGedcomBytes(file.bytes!);
      } else if (file.path != null) {
        text = decodeGedcomBytes(await File(file.path!).readAsBytes());
      } else {
        throw Exception('empty file');
      }
      if (!text.contains('INDI')) {
        throw Exception(l10n.searchEmpty); // 不是有效的 GEDCOM
      }
      final db = ref.read(databaseProvider);
      final treeService = ref.read(treeServiceProvider);
      final name = (file.name.replaceAll(RegExp(r'\.(ged|gedcom|txt)$', caseSensitive: false), ''));
      final treeId = await treeService.create(
        '${l10n.impNewTreePrefix} · $name',
        description: 'GEDCOM 5.5.1 import',
      );
      final report = await importGedcomInto(db, treeId, text);
      setState(() {
        _report = report;
        _importedTreeId = treeId;
        _fileName = file.name;
      });
    } catch (e) {
      setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
