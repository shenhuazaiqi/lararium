import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../data/db/app_database.dart';
import '../../data/providers.dart';
import '../person/person_sheet.dart';
import '../tree/tree_painter.dart';

/// 12 搜索：对姓名/生卒年/出生地/职业实时过滤。
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key, required this.treeId});

  final String treeId;

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final personsAsync = ref.watch(personsProvider(widget.treeId));
    final colors = Theme.of(context).extension<LarariumColors>()!;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        titleSpacing: 8,
        title: TextField(
          controller: _controller,
          autofocus: true,
          onChanged: (v) => setState(() => _query = v),
          style: TextStyle(fontSize: 14.5, color: colors.ink),
          decoration: InputDecoration(
            hintText: l10n.searchHint,
            prefixIcon: Icon(Icons.search, size: 20, color: colors.ink3),
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
      body: personsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (persons) {
          final q = _query.trim().toLowerCase();
          var list = persons;
          if (q.isNotEmpty) {
            list = persons.where((p) {
              final hay = [
                p.givenName,
                p.surname,
                personYears(p),
                p.birthPlace ?? '',
                p.deathPlace ?? '',
                p.occupation ?? '',
              ].join(' ').toLowerCase();
              return hay.contains(q);
            }).toList();
          }
          if (list.isEmpty) {
            return Center(
              child: Text(l10n.searchEmpty,
                  style: TextStyle(fontSize: 13.5, color: colors.ink3)),
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: Text(l10n.foundCount(list.length).toUpperCase(),
                    style: TextStyle(
                        fontSize: 12.5,
                        letterSpacing: 0.6,
                        fontWeight: FontWeight.w700,
                        color: colors.ink3)),
              ),
              Container(
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.line),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    for (var i = 0; i < list.length; i++) ...[
                      if (i > 0) Divider(color: colors.line, height: 1),
                      _row(context, list[i], l10n, colors),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _row(BuildContext context, Person p, AppLocalizations l10n,
      LarariumColors colors) {
    final dead = !p.isLiving;
    final initials = ((p.givenName.isNotEmpty ? p.givenName[0] : '') +
        (p.surname.isNotEmpty ? p.surname[0] : ''));
    final palette = avatarColorsFor(p.id);
    return InkWell(
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) => PersonSheet(personId: p.id),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
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
              child: Text(initials.trim().toUpperCase(),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${p.givenName} ${p.surname}'.trim(),
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: colors.ink)),
                  const SizedBox(height: 2),
                  Text(personYears(p),
                      style: TextStyle(fontSize: 12.5, color: colors.ink3)),
                ],
              ),
            ),
            if (dead)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9),
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.plumSoft,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(l10n.tagRemembered,
                    style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: colors.plum)),
              ),
          ],
        ),
      ),
    );
  }
}
