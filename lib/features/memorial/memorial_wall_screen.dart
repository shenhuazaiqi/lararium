import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../data/db/app_database.dart';
import '../../data/providers.dart';
import '../tree/tree_painter.dart';
import 'memorial_theme_defs.dart';

/// 03 纪念墙：树内已故人物卡片 + 最近被缅怀排序。
class MemorialWallScreen extends ConsumerStatefulWidget {
  const MemorialWallScreen({super.key, required this.treeId});

  final String treeId;

  @override
  ConsumerState<MemorialWallScreen> createState() =>
      _MemorialWallScreenState();
}

enum _WallFilter { all, recent, month, anniv }

class _MemorialWallScreenState extends ConsumerState<MemorialWallScreen> {
  _WallFilter _filter = _WallFilter.all;

  @override
  Widget build(BuildContext context) {
    final personsAsync = ref.watch(personsProvider(widget.treeId));
    final colors = Theme.of(context).extension<LarariumColors>()!;
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();

    return personsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (persons) {
        final dead = persons.where((p) => !p.isLiving).toList();
        var list = switch (_filter) {
          _WallFilter.all =>
            dead.toList()..sort(_byLastMemorialDesc),
          _WallFilter.recent => dead
              .where((p) => p.lastMemorialAt != null)
              .toList()
            ..sort(_byLastMemorialDesc),
          _WallFilter.month => dead
              .where((p) => p.deathDate?.month == now.month)
              .toList(),
          _WallFilter.anniv => dead.toList()
            ..sort((a, b) => _daysToAnniv(a.deathDate, now)
                .compareTo(_daysToAnniv(b.deathDate, now))),
        };
        final tributes = dead.fold<int>(
            0, (sum, p) => sum + p.flowerCount + p.candleCount + p.incenseCount + p.prayerCount + p.messageCount);

        return Scaffold(
          backgroundColor: colors.bg,
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.wallTitle,
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.8,
                        color: colors.ink)),
                Text(
                  l10n.wallSubtitle(dead.length, tributes),
                  style: TextStyle(fontSize: 13.5, color: colors.ink3),
                ),
              ],
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            children: [
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _chip(l10n.wallChipAll, _WallFilter.all, colors),
                    const SizedBox(width: 7),
                    _chip(l10n.wallChipRecent, _WallFilter.recent, colors),
                    const SizedBox(width: 7),
                    _chip(l10n.wallChipMonth, _WallFilter.month, colors),
                    const SizedBox(width: 7),
                    _chip(l10n.wallChipAnniv, _WallFilter.anniv, colors),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              if (list.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 60),
                  child: Center(
                    child: Text(l10n.searchEmpty,
                        style:
                            TextStyle(fontSize: 13.5, color: colors.ink3)),
                  ),
                )
              else
                ...list.map((p) => _card(context, p, l10n, colors)),
            ],
          ),
        );
      },
    );
  }

  static int _daysToAnniv(DateTime? d, DateTime now) {
    if (d == null) return 9999;
    var next = DateTime(now.year, d.month, d.day);
    if (next.isBefore(DateTime(now.year, now.month, now.day))) {
      next = DateTime(now.year + 1, d.month, d.day);
    }
    return next.difference(DateTime(now.year, now.month, now.day)).inDays;
  }

  static int _byLastMemorialDesc(Person a, Person b) {
    final av = a.lastMemorialAt?.millisecondsSinceEpoch ?? 0;
    final bv = b.lastMemorialAt?.millisecondsSinceEpoch ?? 0;
    return bv.compareTo(av);
  }

  Widget _chip(String label, _WallFilter f, LarariumColors colors) {
    final on = _filter == f;
    return GestureDetector(
      onTap: () => setState(() => _filter = f),
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: on ? colors.ink : colors.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: on ? colors.ink : colors.line),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: on ? colors.bg : colors.ink2)),
      ),
    );
  }

  Widget _card(BuildContext context, Person p, AppLocalizations l10n,
      LarariumColors colors) {
    final initials = ((p.givenName.isNotEmpty ? p.givenName[0] : '') +
            (p.surname.isNotEmpty ? p.surname[0] : ''))
        .toUpperCase();
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.line),
      ),
      child: Row(
        children: [
          _avatar(p, initials, colors),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${p.givenName} ${p.surname}'.trim(),
                    style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w600,
                        color: colors.ink)),
                const SizedBox(height: 2),
                Text(personYears(p),
                    style: TextStyle(fontSize: 12.5, color: colors.ink3)),
                const SizedBox(height: 7),
                Text(
                  '${l10n.flowersCount(p.flowerCount)} · ${l10n.candlesCount(p.candleCount)} · ${l10n.messagesCount(p.messageCount)}',
                  style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: colors.ink3),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: () => context.push('/memorial/${p.id}'),
            style: OutlinedButton.styleFrom(
              foregroundColor: colors.ink,
              side: BorderSide(color: colors.line2),
              minimumSize: const Size(64, 38),
              padding: EdgeInsets.zero,
            ),
            child: Text(l10n.visit,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _avatar(Person p, String initials, LarariumColors colors) {
    final palette = avatarColorsFor(p.id);
    final dead = !p.isLiving;
    return Container(
      width: 48,
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: dead
              ? [desaturate(palette[0]), desaturate(palette[1])]
              : palette,
        ),
      ),
      child: Text(initials,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600)),
    );
  }
}
