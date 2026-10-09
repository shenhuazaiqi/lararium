import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/locale_resolver.dart';
import '../../core/theme.dart';
import '../../data/providers.dart';
import '../memorial/theme_picker_sheet.dart';

/// 语言名称按惯例以各自母语显示（数据，不参与翻译）。
const kLanguageNames = {
  'en': 'English',
  'es': 'Español',
  'pt': 'Português',
  'fr': 'Français',
  'de': 'Deutsch',
  'it': 'Italiano',
  'ja': '日本語',
  'ko': '한국어',
  'zh-Hans': '简体中文',
  'zh-Hant': '繁體中文',
  'ru': 'Русский',
  'nl': 'Nederlands',
};

Future<void> showLanguageSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => const _LanguageSheet(),
  );
}

Future<void> showMemorialThemeSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => const ThemePickerSheet(), // personId = null → 全局默认
  );
}

class _LanguageSheet extends ConsumerStatefulWidget {
  const _LanguageSheet();

  @override
  ConsumerState<_LanguageSheet> createState() => _LanguageSheetState();
}

class _LanguageSheetState extends ConsumerState<_LanguageSheet> {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<LarariumColors>()!;
    final l10n = AppLocalizations.of(context);
    final current = ref.watch(localeOverrideProvider);

    Widget item(String? tag, String label, String sub) {
      final selected = current == tag;
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Material(
          color: selected ? colors.brandSoft : colors.surface,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              ref.read(localeOverrideProvider.notifier).state = tag;
              final prefs = ref.read(prefsProvider);
              if (tag == null) {
                prefs.remove('locale_override');
              } else {
                prefs.setString('locale_override', tag);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: selected ? colors.brand : colors.line, width: 1.5),
              ),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected ? colors.brand : Colors.transparent,
                      border: Border.all(
                          color: selected ? colors.brand : colors.line2,
                          width: 1.5),
                    ),
                    child: selected
                        ? const Icon(Icons.check,
                            size: 12, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label,
                            style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                                color: colors.ink)),
                        Text(sub,
                            style: TextStyle(
                                fontSize: 12, color: colors.ink3)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(l10n.language,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: colors.ink)),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(l10n.langDetectedSub,
                  style: TextStyle(fontSize: 13, color: colors.ink3)),
            ),
            const SizedBox(height: 14),
            item(null, l10n.followSystem,
                LocaleResolver.tagOf(Localizations.localeOf(context))),
            for (final tag in LocaleResolver.supportedTags)
              item(tag, kLanguageNames[tag] ?? tag, tag),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(
                  backgroundColor: colors.brand,
                  minimumSize: const Size.fromHeight(46),
                ),
                child: Text(l10n.done),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
