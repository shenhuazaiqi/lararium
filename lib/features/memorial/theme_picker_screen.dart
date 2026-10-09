import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../data/db/app_database.dart';
import '../../data/providers.dart';
import 'memorial_theme_defs.dart';

/// 06 缅怀方式选择（独立页面，替代弹层）：
/// 点选即保存并返回；带「推荐」徽标（按地区推荐，规划 5.4.3）。
/// [personId] 传人物 id → 人物级保存；null → 全局默认。
class ThemePickerScreen extends ConsumerStatefulWidget {
  const ThemePickerScreen({super.key, this.personId});

  final String? personId;

  @override
  ConsumerState<ThemePickerScreen> createState() => _ThemePickerScreenState();
}

class _ThemePickerScreenState extends ConsumerState<ThemePickerScreen> {
  String? _saving; // 防连点

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<LarariumColors>()!;
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final recommended = resolveRegionTheme(locale);

    String current;
    if (widget.personId != null) {
      current = ref.watch(personProvider(widget.personId!)).value
              ?.memorialTheme ??
          recommended;
    } else {
      current = ref.watch(memorialDefaultThemeProvider) ?? recommended;
    }

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        title: Text(l10n.themeTitle,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 30),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Text(l10n.themeSub,
                style: TextStyle(fontSize: 13.5, height: 1.5, color: colors.ink3)),
          ),
          for (final th in memorialThemes)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _item(th, current, recommended, l10n, colors),
            ),
        ],
      ),
    );
  }

  Future<void> _pick(MemorialThemeDef th) async {
    if (_saving != null) return;
    setState(() => _saving = th.key);
    final db = ref.read(databaseProvider);
    if (widget.personId != null) {
      await (db.update(db.persons)..where((p) => p.id.equals(widget.personId!)))
          .write(PersonsCompanion(memorialTheme: Value(th.key)));
    } else {
      ref.read(memorialDefaultThemeProvider.notifier).state = th.key;
      await ref
          .read(prefsProvider)
          .setString('memorial_default_theme', th.key);
    }
    if (mounted) context.pop();
  }

  Widget _item(MemorialThemeDef th, String current, String recommended,
      AppLocalizations l10n, LarariumColors colors) {
    final selected = current == th.key;
    final isRecommended = th.key == recommended;
    return Material(
      color: selected ? colors.brandSoft : colors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _pick(th),
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
                    Row(
                      children: [
                        Flexible(
                          child: Text(th.label(l10n),
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: colors.ink)),
                        ),
                        if (isRecommended) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 7),
                            height: 20,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: colors.brandSoft,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(l10n.recommended,
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: colors.brand)),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(themeDesc(l10n, th.key),
                        style: TextStyle(fontSize: 12.5, color: colors.ink3)),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Row(
                children: [
                  for (final c in th.swatches)
                    Container(
                      width: 14,
                      height: 14,
                      margin: const EdgeInsets.only(left: 3),
                      decoration:
                          BoxDecoration(shape: BoxShape.circle, color: c),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
