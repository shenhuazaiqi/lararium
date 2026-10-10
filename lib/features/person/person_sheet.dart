import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Family;
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../data/db/app_database.dart';
import '../../data/providers.dart';
import '../tree/tree_painter.dart' show avatarColorsFor, desaturate;

/// 10 人物详情底部 Sheet（规划文档：编辑用底部 Sheet，绝不弹窗套弹窗）。
class PersonSheet extends ConsumerWidget {
  const PersonSheet({super.key, required this.personId});

  final String personId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final personAsync = ref.watch(personProvider(personId));
    final colors = Theme.of(context).extension<LarariumColors>()!;
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();

    return personAsync.when(
      loading: () => const SizedBox(height: 200),
      error: (e, _) => SizedBox(height: 120, child: Center(child: Text('$e'))),
      data: (person) {
        if (person == null) {
          return const SizedBox(height: 120, child: Center(child: Text('—')));
        }
        final p = person;
        final dead = !p.isLiving;
        final initials = ((p.givenName.isNotEmpty ? p.givenName[0] : '') +
                (p.surname.isNotEmpty ? p.surname[0] : ''))
            .toUpperCase();

        // 时间轴数据（P1：从家庭关系计算，无新表）
        final families = ref.watch(familiesProvider(p.treeId)).value ?? const <Family>[];
        final links = ref.watch(childLinksProvider(p.treeId)).value ?? const <FamilyChildLink>[];
        final treePersons = ref.watch(personsProvider(p.treeId)).value ?? const <Person>[];
        final timeline = <(int, String)>[];
        if (p.birthDate != null) {
          timeline.add((p.birthDate!.year, l10n.timelineBirth));
        }
        for (final f in families) {
          final isPartner = f.partner1Id == p.id || f.partner2Id == p.id;
          if (isPartner && f.marriageDate != null) {
            timeline.add((f.marriageDate!.year, l10n.timelineMarriage));
          }
          if (isPartner) {
            for (final l in links) {
              if (l.familyId != f.id) continue;
              final child = treePersons
                  .where((q) => q.id == l.personId && q.birthDate != null)
                  .firstOrNull;
              if (child != null) {
                timeline.add((
                  child.birthDate!.year,
                  l10n.timelineChildBorn(
                      '${child.givenName} ${child.surname}'.trim()),
                ));
              }
            }
          }
        }
        if (dead && p.deathDate != null) {
          timeline.add((p.deathDate!.year, l10n.timelineDeath));
        }
        timeline.sort((x, y) => x.$1.compareTo(y.$1));

        final facts = <(String, String)>[
          (l10n.born, bornLine(p, locale)),
          if (dead) (l10n.died, diedLine(p, locale)),
          if (dead && (p.burialPlace?.isNotEmpty ?? false))
            (l10n.buried, p.burialPlace!),
          (l10n.occupation, p.occupation ?? '—'),
        ];

        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.82,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Avatar(
                        person: p,
                        initials: initials,
                        size: 62,
                        fontSize: 21,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              personDisplayName(p, Localizations.localeOf(context)),
                              style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w700,
                                  color: colors.ink),
                            ),
                            const SizedBox(height: 2),
                            Text(personYears(p),
                                style: TextStyle(
                                    fontSize: 13.5, color: colors.ink3)),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: l10n.editPerson,
                        onPressed: () {
                          Navigator.of(context).pop();
                          context.push('/person/edit/${p.id}');
                        },
                        icon: Icon(Icons.edit_outlined,
                            size: 20, color: colors.ink2),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (dead) ...[
                    const SizedBox(height: 10),
                    _MemorialCard(person: p),
                  ],
                  const SizedBox(height: 16),
                  _SectionTitle(l10n.factsSection),
                  Container(
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colors.line),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Column(
                      children: [
                        for (var i = 0; i < facts.length; i++) ...[
                          if (i > 0) Divider(color: colors.line, height: 1),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 104,
                                  child: Text(facts[i].$1,
                                      style: TextStyle(
                                          fontSize: 13, color: colors.ink3)),
                                ),
                                Expanded(
                                  child: Text(facts[i].$2,
                                      style: TextStyle(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w500,
                                          color: colors.ink)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  _SectionTitle(l10n.timelineTitle),
                  Container(
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colors.line),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    child: Column(
                      children: [
                        for (final t in timeline)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 7),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 52,
                                  child: Text('${t.$1}',
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: colors.brand)),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(t.$2,
                                      style: TextStyle(
                                          fontSize: 14, color: colors.ink)),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  _SectionTitle(l10n.addRelativeSection),
                  Row(
                    children: [
                      _relBtn(context, l10n.relParent, 'parent', colors),
                      const SizedBox(width: 8),
                      _relBtn(context, l10n.relSpouse, 'spouse', colors),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _relBtn(context, l10n.relChild, 'child', colors),
                      const SizedBox(width: 8),
                      _relBtn(context, l10n.relSibling, 'sibling', colors),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _relBtn(
      BuildContext context, String label, String rel, LarariumColors colors) {
    return Expanded(
      child: Material(
        color: colors.surface2,
        borderRadius: BorderRadius.circular(11),
        child: InkWell(
          borderRadius: BorderRadius.circular(11),
          onTap: () {
            Navigator.of(context).pop();
            context.push('/person/add/$personId?rel=$rel');
          },
          child: Container(
            height: 38,
            alignment: Alignment.center,
            child: Text(label,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colors.ink)),
          ),
        ),
      ),
    );
  }

  String _displayName(Person p) {
    final full = '${p.givenName} ${p.surname}'.trim();
    return full.isEmpty ? '—' : full;
  }

  List<Color> _avatarFor(String id) => avatarColorsFor(id);

  List<Color> _grey(Person p) {
    final c = avatarColorsFor(p.id);
    return [desaturate(c[0]), desaturate(c[1])];
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<LarariumColors>()!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Text(text.toUpperCase(),
          style: TextStyle(
              fontSize: 12.5,
              letterSpacing: 0.6,
              fontWeight: FontWeight.w700,
              color: colors.ink3)),
    );
  }
}

class _MemorialCard extends ConsumerWidget {
  const _MemorialCard({required this.person});

  final Person person;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<LarariumColors>()!;
    final l10n = AppLocalizations.of(context);
    return Material(
      color: colors.plumSoft,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(context).pop();
          context.push('/memorial/${person.id}');
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(Icons.local_florist_outlined, color: colors.plum, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.inLovingMemory,
                        style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            color: colors.ink)),
                    const SizedBox(height: 2),
                    Text(
                      '${l10n.flowersCount(person.flowerCount)} · ${l10n.candlesCount(person.candleCount)} · ${l10n.messagesCount(person.messageCount)}',
                      style: TextStyle(fontSize: 12.5, color: colors.ink3),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: colors.ink4),
            ],
          ),
        ),
      ),
    );
  }
}

/// 头像组件：登录且有照片 → 私密桶签名 URL 网络图；否则字母渐变。
class _Avatar extends ConsumerWidget {
  const _Avatar({
    required this.person,
    required this.initials,
    required this.size,
    required this.fontSize,
  });

  final Person person;
  final String initials;
  final double size;
  final double fontSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dead = !person.isLiving;
    final palette = avatarColorsFor(person.id);
    final colors2 = dead
        ? [desaturate(palette[0]), desaturate(palette[1])]
        : palette;

    final placeholder = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors2,
        ),
      ),
      child: Text(initials,
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: fontSize)),
    );

    final path = person.avatarPath;
    if (path == null || path.isEmpty) return placeholder;

    return FutureBuilder<String?>(
      future: ref.read(photoServiceProvider).signedUrl(path),
      builder: (context, snap) {
        final url = snap.data;
        if (url == null) return placeholder;
        return ClipOval(
          child: CachedNetworkImage(
            imageUrl: url,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorWidget: (_, __, ___) => placeholder,
          ),
        );
      },
    );
  }
}
