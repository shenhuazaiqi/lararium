import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/capture.dart';
import '../../core/theme.dart';
import '../../data/providers.dart';
import 'export_service.dart';

/// 07 导出中心：PDF 海报 / PNG 高清图 / GEDCOM 5.5.1 / JSON 全量备份。
class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  ExportFormat _format = ExportFormat.pdf;
  bool _includeLiving = true;
  bool _poster2x = false;
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<LarariumColors>()!;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        title: Text(l10n.exportTitle,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 30),
        children: [
          _option(
            colors,
            icon: Icons.picture_as_pdf_outlined,
            title: l10n.exportPdfPoster,
            subtitle: l10n.exportPdfSub,
            selected: _format == ExportFormat.pdf,
            onTap: () => setState(() => _format = ExportFormat.pdf),
          ),
          const SizedBox(height: 10),
          _option(
            colors,
            icon: Icons.image_outlined,
            title: l10n.exportPng,
            subtitle: l10n.exportPngSub,
            selected: _format == ExportFormat.png,
            onTap: () => setState(() => _format = ExportFormat.png),
          ),
          const SizedBox(height: 10),
          _option(
            colors,
            icon: Icons.description_outlined,
            title: l10n.exportGedcom,
            subtitle: l10n.exportGedcomSub,
            selected: _format == ExportFormat.gedcom,
            onTap: () => setState(() => _format = ExportFormat.gedcom),
          ),
          const SizedBox(height: 10),
          _option(
            colors,
            icon: Icons.settings_backup_restore,
            title: l10n.exportJson,
            subtitle: l10n.exportJsonSub,
            selected: _format == ExportFormat.json,
            onTap: () => setState(() => _format = ExportFormat.json),
          ),
          const SizedBox(height: 22),
          _section(l10n.styleSection, colors),
          _list(colors, [
            SwitchListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              title: Text(l10n.includeLiving,
                  style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w500,
                      color: colors.ink)),
              value: _includeLiving,
              onChanged: (v) => setState(() => _includeLiving = v),
            ),
            if (_format == ExportFormat.pdf) ...[
              Divider(color: colors.line, height: 1, indent: 14, endIndent: 14),
              SwitchListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                title: Text(l10n.poster2x,
                    style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w500,
                        color: colors.ink)),
                value: _poster2x,
                onChanged: (v) => setState(() => _poster2x = v),
              ),
            ],
          ]),
          const SizedBox(height: 24),
          SizedBox(
            height: 50,
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
                  : const Icon(Icons.ios_share, size: 18),
              label: Text(l10n.btnExport,
                  style: const TextStyle(
                      fontSize: 15.5, fontWeight: FontWeight.w600)),
              onPressed: _busy ? null : _run,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _run() async {
    final treeId = ref.read(effectiveTreeIdProvider);
    if (treeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context).exportEmpty)));
      return;
    }
    setState(() => _busy = true);
    try {
      final service = ExportService(ref.read(databaseProvider));
      final l10n = AppLocalizations.of(context);
      ExportResult? result;
      switch (_format) {
        case ExportFormat.pdf:
          final tree = await (ref.read(databaseProvider).select(
                  ref.read(databaseProvider).trees)
                ..where((t) => t.id.equals(treeId)))
              .getSingleOrNull();
          final png = await captureTreePngSafe();
          result = await service.exportPdf(
            tree?.name ?? 'Lararium',
            poster2x: _poster2x,
            treePng: png,
          );
          break;
        case ExportFormat.png:
          result = await service.exportPng('tree');
          break;
        case ExportFormat.gedcom:
          result = await service.exportGedcomFile(
              treeId, includeLiving: _includeLiving);
          break;
        case ExportFormat.json:
          result = await service.exportJsonBackup(treeId);
          break;
      }
      if (!mounted) return;
      if (result == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.exportEmpty)));
        return;
      }
      await service.share(result);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.exportSuccess(result.fileName))));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _section(String title, LarariumColors colors) => Padding(
        padding: const EdgeInsets.only(bottom: 9),
        child: Text(title.toUpperCase(),
            style: TextStyle(
                fontSize: 12.5,
                letterSpacing: 0.6,
                fontWeight: FontWeight.w700,
                color: colors.ink3)),
      );

  Widget _list(LarariumColors colors, List<Widget> children) => Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.line),
        ),
        child: Column(children: children),
      );

  Widget _option(
    LarariumColors colors, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: selected ? colors.brandSoft : colors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: selected ? colors.brand : colors.line, width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: colors.surface2,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: colors.brand, size: 22),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: colors.ink)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style:
                            TextStyle(fontSize: 12.5, color: colors.ink3)),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: colors.brandSoft,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(l10nFreeTag,
                    style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: colors.brand)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String get l10nFreeTag => AppLocalizations.of(context).tagFree;
}
