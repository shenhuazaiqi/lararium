import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/locale_resolver.dart';
import '../../core/theme.dart';
import '../../data/providers.dart';

/// 语言选择（独立页面，替代弹层）：
/// 点选即生效并持久化；左上角返回。规划文档 5.3.2「应用内切换即时生效」。
class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<LarariumColors>()!;
    final l10n = AppLocalizations.of(context);
    final current = ref.watch(localeOverrideProvider);

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        title: Text(l10n.language,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 30),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Text(l10n.langDetectedSub,
                style: TextStyle(fontSize: 13.5, color: colors.ink3)),
          ),
          _item(
            context,
            ref,
            colors,
            tag: null,
            label: l10n.followSystem,
            sub: LocaleResolver.tagOf(Localizations.localeOf(context)),
            selected: current == null,
          ),
          for (final tag in LocaleResolver.supportedTags)
            _item(
              context,
              ref,
              colors,
              tag: tag,
              label: kLanguageNames[tag] ?? tag,
              sub: tag,
              selected: current == tag,
            ),
        ],
      ),
    );
  }

  Widget _item(
    BuildContext context,
    WidgetRef ref,
    LarariumColors colors, {
    required String? tag,
    required String label,
    required String sub,
    required bool selected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
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
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: selected ? colors.brand : colors.line, width: 1.5),
            ),
            child: Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? colors.brand : Colors.transparent,
                    border: Border.all(
                        color: selected ? colors.brand : colors.line2,
                        width: 1.5),
                  ),
                  child: selected
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label,
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: colors.ink)),
                      Text(sub,
                          style:
                              TextStyle(fontSize: 12.5, color: colors.ink3)),
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
}

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
