import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme.dart';
import '../../data/providers.dart';
import '../../core/fuzzy_date.dart';
import '../memorial/memorial_theme_defs.dart';
import 'language_screen.dart';
import '../memorial/memorial_wall_screen.dart' show personYears;

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
    final email = ref.watch(authEmailProvider);

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
          // --- Family trees（多树管理：切换/新建/复制，规划 5.2 P0） ---
          _section(l10n.treesSection, colors),
          _treesSection(context, ref, colors, l10n),
          const SizedBox(height: 22),

          // --- General ---
          _section(l10n.generalSection, colors),
          _list(colors, [
            _row(
              context,
              icon: Icons.sync,
              iconColor: colors.brand,
              title: l10n.authCardTitle,
              subtitle: email == null ? l10n.followSystem : l10n.allSynced,
              onTap: () => context.push('/sync'),
            ),
            _divider(colors),
            _row(
              context,
              icon: Icons.picture_as_pdf_outlined,
              iconColor: colors.ink2,
              title: l10n.exportTitle,
              subtitle: 'PDF · PNG · GEDCOM',
              onTap: () => context.push('/export'),
            ),
            _divider(colors),
            _row(
              context,
              icon: Icons.notifications_none,
              iconColor: colors.ink2,
              title: l10n.remTitle,
              subtitle: l10n.remAnniv,
              onTap: () => context.push('/reminders'),
            ),
            _divider(colors),
            _row(
              context,
              icon: Icons.language,
              iconColor: colors.ink2,
              title: l10n.language,
              subtitle: langLabel,
              onTap: () => context.push('/settings/language'),
            ),
            _divider(colors),
            _row(
              context,
              icon: Icons.workspace_premium_outlined,
              iconColor: colors.amber,
              title: l10n.proTitle,
              subtitle: l10n.proPriceSub,
              onTap: () => context.push('/pro'),
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
              onTap: () => context.push('/settings/memorial-style'),
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
              icon: Icons.description_outlined,
              iconColor: colors.ink2,
              title: l10n.privacyPolicy,
              subtitle: 'shenhuazaiqi.github.io',
              onTap: () => launchUrl(
                  Uri.parse('https://shenhuazaiqi.github.io/lararium/privacy.html'),
                  mode: LaunchMode.externalApplication),
            ),
            _divider(colors),
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

  Widget _treesSection(BuildContext context, WidgetRef ref,
      LarariumColors colors, AppLocalizations l10n) {
    final treesAsync = ref.watch(treesListProvider);
    final currentId = ref.watch(effectiveTreeIdProvider);
    final service = ref.watch(treeServiceProvider);
    return treesAsync.when(
      loading: () => const LinearProgressIndicator(minHeight: 2),
      error: (e, _) => Text('$e'),
      data: (trees) => _list(colors, [
        for (final t in trees)
          InkWell(
            onTap: () async {
              ref.read(currentTreeIdProvider.notifier).state = t.id;
              await ref.read(prefsProvider).setString('current_tree_id', t.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.treeSwitched(t.name))));
              }
            },
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Icon(t.isDemo ? Icons.school_outlined : Icons.account_tree_outlined,
                      size: 19,
                      color: t.id == currentId ? colors.brand : colors.ink3),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.name,
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: colors.ink)),
                        Text(personYearsFromTree(t),
                            style: TextStyle(
                                fontSize: 12.5, color: colors.ink3)),
                      ],
                    ),
                  ),
                  if (t.id == currentId)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: colors.brandSoft,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Text(l10n.currentTag,
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: colors.brand)),
                    )
                  else
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_horiz,
                          size: 20, color: colors.ink3),
                      onSelected: (action) async {
                        if (action == 'dup') {
                          final newId = await service.duplicate(
                              t.id, '\${t.name} (copy)');
                          ref.read(currentTreeIdProvider.notifier).state =
                              newId;
                          await ref
                              .read(prefsProvider)
                              .setString('current_tree_id', newId);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(l10n.treeDuplicated)));
                          }
                        } else if (action == 'rename') {
                          _renameDialog(context, service, t.id, t.name, l10n);
                        } else if (action == 'del') {
                          final peopleCount = await service.countPeople(t.id);
                          final ok = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: Text(l10n.deleteTreeTitle),
                              content: Text(l10n.deleteTreeBody(
                                  t.name, peopleCount)),
                              actions: [
                                TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: Text(l10n.cancel)),
                                FilledButton(
                                  style: FilledButton.styleFrom(
                                      backgroundColor: colors.danger),
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: Text(l10n.delete)),
                              ],
                            ),
                          );
                          if (ok == true) {
                            await service.softDelete(t.id);
                            if (t.id ==
                                ref.read(currentTreeIdProvider.notifier).state) {
                              final next =
                                  await service.firstRemainingTreeId(exclude: t.id);
                              ref.read(currentTreeIdProvider.notifier).state =
                                  next;
                              if (next != null) {
                                await ref
                                    .read(prefsProvider)
                                    .setString('current_tree_id', next);
                              }
                            }
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text(l10n.treeDeleted)));
                            }
                          }
                        }
                      },
                      itemBuilder: (_) => [
                        PopupMenuItem(
                            value: 'dup', child: Text(l10n.duplicateTree)),
                        PopupMenuItem(
                            value: 'rename', child: Text(l10n.renameTree)),
                        PopupMenuItem(
                            value: 'del', child: Text(l10n.deleteTree)),
                      ],
                    ),
                ],
              ),
            ),
          ),
        if (trees.length < 6)
          InkWell(
            onTap: () => _newTreeDialog(context, ref, service, colors, l10n),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              child: Row(
                children: [
                  Icon(Icons.add, size: 20, color: colors.brand),
                  const SizedBox(width: 14),
                  Text(l10n.newTree,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: colors.brand)),
                ],
              ),
            ),
          ),
      ]),
    );
  }

  Future<void> _newTreeDialog(
      BuildContext context,
      WidgetRef ref,
      dynamic service,
      LarariumColors colors,
      AppLocalizations l10n) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.newTree),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: l10n.errTreeName),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.cancel)),
          FilledButton(
              style: FilledButton.styleFrom(backgroundColor: colors.brand),
              onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              child: Text(l10n.done)),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;
    final id = await service.create(name);
    ref.read(currentTreeIdProvider.notifier).state = id;
    await ref.read(prefsProvider).setString('current_tree_id', id);
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.treeCreated)));
    }
  }

  Future<void> _renameDialog(BuildContext context, dynamic service,
      String treeId, String oldName, AppLocalizations l10n) async {
    final controller = TextEditingController(text: oldName);
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.renameTree),
        content: TextField(
          controller: controller,
          autofocus: true,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.cancel)),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              child: Text(l10n.done)),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;
    await service.rename(treeId, name);
  }

  String personYearsFromTree(dynamic t) => t.description ?? '';

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
