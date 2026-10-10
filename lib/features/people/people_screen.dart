import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../data/db/app_database.dart';
import '../../data/providers.dart';
import '../person/person_sheet.dart';
import '../tree/tree_painter.dart';

/// 02 人物列表：Living / Remembered 分组，已故头像去饱和。
class PeopleScreen extends ConsumerWidget {
  const PeopleScreen({super.key, required this.treeId});

  final String treeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final personsAsync = ref.watch(personsProvider(treeId));
    final colors = Theme.of(context).extension<LarariumColors>()!;
    final l10n = AppLocalizations.of(context);

    return personsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (persons) {
        final living = persons.where((p) => p.isLiving).toList();
        final remembered = persons.where((p) => !p.isLiving).toList();
        return Scaffold(
          backgroundColor: colors.bg,
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.peopleTitle,
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.8,
                        color: colors.ink)),
                Text(
                  l10n.peopleCount(persons.length),
                  style: TextStyle(fontSize: 13.5, color: colors.ink3),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.person_add_alt_1_outlined),
                onPressed: () {
                  final self =
                      persons.where((p) => p.isSelf).firstOrNull ?? persons.firstOrNull;
                  if (self != null) context.push('/person/add/${self.id}');
                },
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => context.push('/search'),
                  child: Container(
                    height: 42,
                    padding: const EdgeInsets.symmetric(horizontal: 13),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colors.line),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, size: 18, color: colors.ink3),
                        const SizedBox(width: 9),
                        Text(l10n.searchAction,
                            style:
                                TextStyle(fontSize: 14.5, color: colors.ink3)),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: persons.isEmpty
                    ? _emptyState(context, colors, l10n)
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                        children: [
                          _group(context, l10n.groupLiving, living, colors),
                          const SizedBox(height: 20),
                          _group(context, l10n.groupRemembered, remembered, colors),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _emptyState(
      BuildContext context, LarariumColors colors, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_tree_outlined, size: 56, color: colors.ink4),
          const SizedBox(height: 14),
          Text(l10n.addFirstPerson,
              style: TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w600,
                  color: colors.ink)),
          const SizedBox(height: 6),
          Text(l10n.addFirstPersonSub,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.5, color: colors.ink3)),
          const SizedBox(height: 18),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: colors.brand,
              minimumSize: const Size(200, 48),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            icon: const Icon(Icons.person_add_alt_1, size: 18),
            label: Text(l10n.personNew),
            onPressed: () => context.push('/person/new'),
          ),
        ],
      ),
    );
  }

  Widget _group(BuildContext context, String title, List<Person> people,
      LarariumColors colors) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 9),
          child: Text('$title · ${people.length}'.toUpperCase(),
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
              for (var i = 0; i < people.length; i++) ...[
                if (i > 0) Divider(color: colors.line, height: 1),
                _personRow(context, people[i], l10n, colors),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _personRow(
      BuildContext context, Person p, AppLocalizations l10n, LarariumColors colors) {
    final dead = !p.isLiving;
    final initials = ((p.givenName.isNotEmpty ? p.givenName[0] : '') +
            (p.surname.isNotEmpty ? p.surname[0] : ''))
        .toUpperCase();
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
              width: 40,
              height: 40,
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
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(personDisplayName(p, Localizations.localeOf(context)),
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
            Icon(Icons.chevron_right, size: 18, color: colors.ink4),
          ],
        ),
      ),
    );
  }
}
