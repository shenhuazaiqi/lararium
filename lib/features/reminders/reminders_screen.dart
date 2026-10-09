import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../data/db/app_database.dart';
import '../../data/providers.dart';
import 'reminder_service.dart';

/// 14 提醒中心：忌日/生日开关、提醒时间、提前天数 + 未来 30 天列表。
class RemindersScreen extends ConsumerStatefulWidget {
  const RemindersScreen({super.key});

  @override
  ConsumerState<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends ConsumerState<RemindersScreen> {
  @override
  Widget build(BuildContext context) {
    final treeId = ref.watch(effectiveTreeIdProvider);
    final personsAsync = ref.watch(personsProvider(treeId ?? ''));
    final colors = Theme.of(context).extension<LarariumColors>()!;
    final l10n = AppLocalizations.of(context);
    final prefs = ref.watch(prefsProvider);

    final annivOn = prefs.getBool('rem_anniv') ?? true;
    final birthOn = prefs.getBool('rem_birth') ?? false;
    final daysAhead = prefs.getInt('rem_days_ahead') ?? 0;

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        title: Text(l10n.remTitle,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
      ),
      body: personsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (persons) {
          final localeTag = Localizations.localeOf(context).toString();
          final upcoming = _upcoming(persons, localeTag, l10n);
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 30),
            children: [
              _list(colors, [
                SwitchListTile(
                  secondary:
                      Icon(Icons.local_florist_outlined, color: colors.amber),
                  title: Text(l10n.remAnniv,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: colors.ink)),
                  subtitle: Text(l10n.remUpcoming(_countUpcoming(persons, true)),
                      style:
                          TextStyle(fontSize: 12.5, color: colors.ink3)),
                  value: annivOn,
                  onChanged: (v) async {
                    await prefs.setBool('rem_anniv', v);
                    setState(() {});
                    await _reschedule(persons);
                  },
                ),
                Divider(color: colors.line, height: 1, indent: 52),
                SwitchListTile(
                  secondary: Icon(Icons.cake_outlined, color: colors.ink2),
                  title: Text(l10n.remBirth,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: colors.ink)),
                  subtitle: Text(
                      l10n.remUpcoming(_countUpcoming(persons, false)),
                      style: TextStyle(fontSize: 12.5, color: colors.ink3)),
                  value: birthOn,
                  onChanged: (v) async {
                    await prefs.setBool('rem_birth', v);
                    setState(() {});
                    await _reschedule(persons);
                  },
                ),
              ]),
              const SizedBox(height: 20),
              _section(l10n.remTime.toUpperCase(), colors),
              _list(colors, [
                ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                  title: Text(l10n.remTime,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: colors.ink)),
                  trailing: Text('9:00 AM',
                      style: TextStyle(fontSize: 14, color: colors.ink3)),
                ),
                Divider(color: colors.line, height: 1, indent: 14, endIndent: 14),
                ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                  title: Text(l10n.remDays,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: colors.ink)),
                  trailing: DropdownButton<int>(
                    value: daysAhead,
                    underline: const SizedBox.shrink(),
                    items: [
                      DropdownMenuItem(value: 0, child: Text(l10n.remSameDay)),
                      DropdownMenuItem(value: 1, child: Text(l10n.rem1Day)),
                      DropdownMenuItem(value: 3, child: Text(l10n.rem3Days)),
                      DropdownMenuItem(value: 7, child: Text(l10n.rem7Days)),
                    ],
                    onChanged: (v) async {
                      await prefs.setInt('rem_days_ahead', v ?? 0);
                      setState(() {});
                      await _reschedule(persons);
                    },
                  ),
                ),
              ]),
              const SizedBox(height: 20),
              _section(l10n.upcomingThisMonth.toUpperCase(), colors),
              if (upcoming.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(l10n.noUpcoming,
                        style: TextStyle(fontSize: 13.5, color: colors.ink3)),
                  ),
                )
              else
                ...upcoming.map((u) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: colors.line),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              u.$3
                                  ? Icons.local_florist_outlined
                                  : Icons.cake_outlined,
                              size: 20,
                              color: u.$3 ? colors.amber : colors.ink2,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(u.$1,
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: colors.ink)),
                            ),
                            Text(u.$2,
                                style: TextStyle(
                                    fontSize: 12.5, color: colors.ink3)),
                          ],
                        ),
                      ),
                    )),
              const SizedBox(height: 14),
              Center(
                child: Text(l10n.remFreeNote,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 11.5, height: 1.6, color: colors.ink4)),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _reschedule(List<Person> persons) async {
    final prefs = ref.read(prefsProvider);
    final annivOn = prefs.getBool('rem_anniv') ?? true;
    final birthOn = prefs.getBool('rem_birth') ?? false;
    final daysAhead = prefs.getInt('rem_days_ahead') ?? 0;
    final events = <({String name, DateTime date, bool isAnniversary})>[];
    for (final p in persons) {
      if (annivOn && !p.isLiving && p.deathDate != null) {
        events.add((name: '${p.givenName} ${p.surname}'.trim(), date: p.deathDate!, isAnniversary: true));
      }
      if (birthOn && p.birthDate != null) {
        events.add((name: '${p.givenName} ${p.surname}'.trim(), date: p.birthDate!, isAnniversary: false));
      }
    }
    await ReminderService.instance.init();
    await ReminderService.instance.scheduleUpcoming(
      events: events,
      enabled: true,
      daysAhead: daysAhead,
      prefs: prefs,
    );
  }

  int _countUpcoming(List<Person> persons, bool anniv) {
    final now = DateTime.now();
    var n = 0;
    for (final p in persons) {
      final d = anniv ? (p.isLiving ? null : p.deathDate) : p.birthDate;
      if (d == null) continue;
      final next = DateTime(now.year, d.month, d.day);
      final diff = next.difference(DateTime(now.year, now.month, now.day)).inDays;
      if (diff >= 0 && diff <= 30) n++;
    }
    return n;
  }

  List<(String, String, bool)> _upcoming(
      List<Person> persons, String localeTag, AppLocalizations l10n) {
    final now = DateTime.now();
    final out = <(String, String, bool)>[];
    for (final p in persons) {
      // 忌日
      if ((!p.isLiving) && p.deathDate != null) {
        final next = DateTime(now.year, p.deathDate!.month, p.deathDate!.day);
        final diff = next.difference(DateTime(now.year, now.month, now.day)).inDays;
        if (diff >= 0 && diff <= 30) {
          out.add((
            l10n.annivOf('${p.givenName} ${p.surname}'.trim()),
            _fmt(next),
            true,
          ));
        }
      }
      // 生日
      if (p.birthDate != null) {
        final next = DateTime(now.year, p.birthDate!.month, p.birthDate!.day);
        final diff = next.difference(DateTime(now.year, now.month, now.day)).inDays;
        if (diff >= 0 && diff <= 30) {
          out.add((
            l10n.birthdayOf('${p.givenName} ${p.surname}'.trim()),
            _fmt(next),
            false,
          ));
        }
      }
    }
    out.sort((a, b) => a.$2.compareTo(b.$2));
    return out;
  }

  String _fmt(DateTime d) =>
      '${d.month}/${d.day}';

  Widget _section(String title, LarariumColors colors) => Padding(
        padding: const EdgeInsets.only(bottom: 9),
        child: Text(title,
            style: TextStyle(
                fontSize: 12.5,
                letterSpacing: 0.6,
                fontWeight: FontWeight.w700,
                color: colors.ink3)),
      );

  Widget _list(LarariumColors colors, List<Widget> children) => Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.line),
        ),
        child: Column(children: children),
      );
}
