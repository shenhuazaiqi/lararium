import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../data/providers.dart';
import '../memorial/memorial_theme_defs.dart';
import 'settings_sheets.dart';

/// 04 设置。
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<LarariumColors>()!;
    final l10n = AppLocalizations.of(context);
    final prefs = ref.watch(prefsProvider);
    final themeMode = ref.watch(themeModeProvider);
    final localeOverride = ref.watch(localeOverrideProvider);
    final defaultTheme = ref.watch(memorialDefaultThemeProvider);
    final locale = Localizations.localeOf(context);

    String langLabel;
    if (localeOverride != null) {
      langLabel = _langName(localeOverride);
    } else {
      langLabel = l10n.followSystem;
    }

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        title: Text(l10n.settingsTitle,
            style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.8,
                color: colors.ink)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
        children: [
          const SizedBox(height: 4),
          // --- General ---
          _section(l10n.generalSection, colors),
          _list(colors, [
            _row(
              context,
              icon: Icons.language,
              iconColor: colors.ink2,
              title: l10n.language,
              subtitle: langLabel,
              onTap: () => showLanguageSheet(context),
            ),
            _divider(colors),
            _row(
              context,
              icon: Icons.local_florist_outlined,
              iconColor: colors.amber,
              title: l10n.memorialDefaultStyle,
              subtitle: defaultTheme == null
                  ? l10n.followSystem
                  : themeByKey(defaultTheme).label(l10n),
              onTap: () => showMemorialThemeSheet(context),
            ),
            _divider(colors),
            SwitchListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              secondary: Icon(Icons.dark_mode_outlined,
                  size: 19, color: colors.ink2),
              title: Text(l10n.darkMode,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: colors.ink)),
              value: themeMode.isDark,
              onChanged: (v) {
                final next =
                    v ? ThemeModePrefs.dark : ThemeModePrefs.system;
                ref.read(themeModeProvider.notifier).state = next;
                prefs.setString('theme_mode', next.value);
              },
            ),
          ]),
          const SizedBox(height: 22),

          // --- Privacy ---
          _section(l10n.privacySection, colors),
          _list(colors, [
            _row(
              context,
              icon: Icons.lock_outline,
              iconColor: colors.ink2,
              title: l10n.livingPrivateTitle,
              subtitle: l10n.livingPrivateSub,
            ),
            _divider(colors),
            _row(
              context,
              icon: Icons.delete_outline,
              iconColor: colors.danger,
              title: l10n.deleteAccountData,
              danger: true,
              onTap: () {
                // 账号删除入口属阶段 3 合规项（应用内 + 网页端）
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.comingSoon)));
              },
            ),
          ]),
          const SizedBox(height: 22),
          Center(
            child: Text(
              l10n.versionLine('0.1.0'),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11.5, color: colors.ink4),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              '${l10n.appTagline} · ${locale.languageCode}',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11.5, color: colors.ink4),
            ),
          ),
        ],
      ),
    );
  }

  String _langName(String tag) {
    const names = {
      'en': 'English', 'es': 'Español', 'pt': 'Português', 'fr': 'Français',
      'de': 'Deutsch', 'it': 'Italiano', 'ja': '日本語', 'ko': '한국어',
      'zh-Hans': '简体中文', 'zh-Hant': '繁體中文', 'ru': 'Русский',
      'nl': 'Nederlands',
    };
    return names[tag] ?? tag;
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

  Widget _divider(LarariumColors colors) =>
      Divider(color: colors.line, height: 1, indent: 52);

  Widget _list(LarariumColors colors, List<Widget> children) => Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.line),
        ),
        child: Column(children: children),
      );

  Widget _row(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    bool danger = false,
  }) {
    final colors = Theme.of(context).extension<LarariumColors>()!;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 19, color: iconColor),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: danger ? colors.danger : colors.ink)),
                  if (subtitle != null && subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style:
                            TextStyle(fontSize: 12.5, color: colors.ink3)),
                  ],
                ],
              ),
            ),
            if (onTap != null)
              Icon(Icons.chevron_right, size: 18, color: colors.ink4),
          ],
        ),
      ),
    );
  }
}
