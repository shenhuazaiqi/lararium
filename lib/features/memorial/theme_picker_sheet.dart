import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../data/db/app_database.dart';
import '../../data/providers.dart';
import 'memorial_theme_defs.dart';

/// 06 缅怀方式选择：按地区推荐预选 + 一次确认层，随时可改（人物级）。
class ThemePickerSheet extends ConsumerStatefulWidget {
  const ThemePickerSheet({super.key, this.personId});

  /// 传入人物 id → 保存到人物；null → 保存为全局默认。
  final String? personId;

  @override
  ConsumerState<ThemePickerSheet> createState() => _ThemePickerSheetState();
}

class _ThemePickerSheetState extends ConsumerState<ThemePickerSheet> {
  late String _selected;
  late final String _recommended;
  bool _init = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<LarariumColors>()!;
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    _recommended = resolveRegionTheme(locale);

    if (!_init) {
      if (widget.personId != null) {
        final p = ref.watch(personProvider(widget.personId!)).value;
        _selected = p?.memorialTheme ?? _recommended;
      } else {
        _selected =
            ref.read(memorialDefaultThemeProvider) ?? _recommended;
      }
      _init = true;
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(l10n.themeTitle,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: colors.ink)),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(l10n.themeSub,
                  style: TextStyle(fontSize: 13, color: colors.ink3)),
            ),
            const SizedBox(height: 14),
            ...memorialThemes.map(_item),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // Cancel：还原为推荐（原型行为）
                      setState(() => _selected = _recommended);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.ink,
                      side: BorderSide(color: colors.line2),
                      minimumSize: const Size.fromHeight(46),
                    ),
                    child: Text(l10n.cancel),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: () => _save(context),
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.brand,
                      minimumSize: const Size.fromHeight(46),
                    ),
                    child: Text(l10n.useRecommended),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save(BuildContext context) async {
    final db = ref.read(databaseProvider);
    if (widget.personId != null) {
      await (db.update(db.persons)
            ..where((p) => p.id.equals(widget.personId!)))
          .write(PersonsCompanion(memorialTheme: Value(_selected)));
    } else {
      ref.read(memorialDefaultThemeProvider.notifier).state = _selected;
    }
    if (context.mounted) Navigator.of(context).pop();
  }

  Widget _item(MemorialThemeDef th) {
    final colors = Theme.of(context).extension<LarariumColors>()!;
    final l10n = AppLocalizations.of(context);
    final selected = _selected == th.key;
    final isRecommended = th.key == _recommended;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: selected ? colors.brandSoft : colors.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => setState(() => _selected = th.key),
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
                      ? const Icon(Icons.check, size: 12, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(th.label(l10n),
                              style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w600,
                                  color: colors.ink)),
                          if (isRecommended) ...[
                            const SizedBox(width: 7),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 7),
                              height: 19,
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
                      const SizedBox(height: 2),
                      Text(themeDesc(l10n, th.key),
                          style:
                              TextStyle(fontSize: 12, color: colors.ink3)),
                    ],
                  ),
                ),
                Row(
                  children: [
                    for (final c in th.swatches)
                      Container(
                        width: 14,
                        height: 14,
                        margin: const EdgeInsets.only(left: 3),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: c),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
