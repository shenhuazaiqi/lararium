import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../core/theme.dart';

/// 07 导出 —— 阶段 2 交付（PDF/PNG/GEDCOM）。当前给出诚实的占位说明。
class ExportScreen extends StatelessWidget {
  const ExportScreen({super.key});

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
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.line),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.picture_as_pdf_outlined,
                  size: 40, color: colors.ink3),
              const SizedBox(height: 14),
              Text(l10n.comingSoon,
                  style: TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w600,
                      color: colors.ink)),
              const SizedBox(height: 8),
              Text(l10n.exportComingSoon,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 13, height: 1.6, color: colors.ink3)),
            ],
          ),
        ),
      ),
    );
  }
}

/// 13 GEDCOM 导入 —— 阶段 2 交付。
class ImportScreen extends StatelessWidget {
  const ImportScreen({super.key});

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
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: colors.surface2,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: colors.line2,
                style: BorderStyle.solid,
                width: 1.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.upload_file_outlined, size: 40, color: colors.ink3),
              const SizedBox(height: 14),
              Text(l10n.comingSoon,
                  style: TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w600,
                      color: colors.ink)),
              const SizedBox(height: 8),
              Text(l10n.importComingSoon,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 13, height: 1.6, color: colors.ink3)),
            ],
          ),
        ),
      ),
    );
  }
}
