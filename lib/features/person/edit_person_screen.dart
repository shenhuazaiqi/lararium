import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/fuzzy_date.dart';
import '../../core/theme.dart';
import '../../data/db/app_database.dart';
import '../../data/providers.dart';
import '../tree/tree_painter.dart';

/// 10 编辑人物：表单预填真实档案；在世者自动隐藏「逝世」字段。
class EditPersonScreen extends ConsumerStatefulWidget {
  const EditPersonScreen({super.key, required this.personId});

  final String personId;

  @override
  ConsumerState<EditPersonScreen> createState() => _EditPersonScreenState();
}

class _EditPersonScreenState extends ConsumerState<EditPersonScreen> {
  final _formKey = GlobalKey<FormState>();
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _born = TextEditingController();
  final _died = TextEditingController();
  final _place = TextEditingController();
  final _burial = TextEditingController();
  final _occ = TextEditingController();
  final _note = TextEditingController();
  String _gender = 'unknown';
  bool _dead = false;
  bool _loaded = false;

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    _born.dispose();
    _died.dispose();
    _place.dispose();
    _burial.dispose();
    _occ.dispose();
    _note.dispose();
    super.dispose();
  }

  void _fill(Person p) {
    _first.text = p.givenName;
    _last.text = p.surname;
    _gender = p.gender;
    _dead = !p.isLiving;
    _born.text = p.birthDate == null
        ? ''
        : FuzzyDate.encode(p.birthDate!, p.birthPrecision);
    _died.text = p.deathDate == null
        ? ''
        : FuzzyDate.encode(p.deathDate!, p.deathPrecision);
    _place.text = p.birthPlace ?? '';
    _burial.text = p.burialPlace ?? '';
    _occ.text = p.occupation ?? '';
    _note.text = p.note ?? '';
    _loaded = true;
  }

  @override
  Widget build(BuildContext context) {
    final personAsync = ref.watch(personProvider(widget.personId));
    final colors = Theme.of(context).extension<LarariumColors>()!;
    final l10n = AppLocalizations.of(context);
    final db = ref.watch(databaseProvider);

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        title: Text(l10n.editPerson,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
      ),
      body: personAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (person) {
          if (person == null) {
            return const Center(child: Text('—'));
          }
          if (!_loaded) _fill(person);
          final initials =
              '${_first.text.isNotEmpty ? _first.text[0] : ''}${_last.text.isNotEmpty ? _last.text[0] : ''}'
                  .toUpperCase();
          final palette = avatarColorsFor(person.id);
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 30),
              children: [
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: _dead
                                ? [
                                    desaturate(palette[0]),
                                    desaturate(palette[1])
                                  ]
                                : palette,
                          ),
                        ),
                        child: Text(
                          initials.isEmpty ? '?' : initials,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 27,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextButton(
                        onPressed: () {
                          // 媒体上传属阶段 3（Supabase Storage + 压缩队列）
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.comingSoon)));
                        },
                        child: Text(l10n.photo),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                _card(colors, [
                  _field(l10n.fFirst, _first, validator: (v) =>
                      (v == null || v.trim().isEmpty) ? l10n.errEnterFirstName : null),
                  _divider(colors),
                  _field(l10n.fLast, _last),
                ]),
                const SizedBox(height: 14),
                _card(colors, [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.fGender,
                            style: TextStyle(
                                fontSize: 13, color: colors.ink3)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [
                            for (final (code, label) in [
                              ('male', l10n.genderMale),
                              ('female', l10n.genderFemale),
                              ('other', l10n.genderOther),
                              ('unknown', l10n.genderUnknown),
                            ])
                              ChoiceChip(
                                label: Text(label),
                                selected: _gender == code,
                                onSelected: (_) => setState(() => _gender = code),
                                selectedColor: colors.brandSoft,
                                labelStyle: TextStyle(
                                  color: _gender == code
                                      ? colors.brand
                                      : colors.ink2,
                                  fontWeight: FontWeight.w600,
                                ),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(9)),
                                side: BorderSide(
                                    color: _gender == code
                                        ? colors.brand
                                        : colors.line2),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ]),
                const SizedBox(height: 14),
                _card(colors, [
                  _field(l10n.fBorn, _born,
                      hint: '1900 or 1900-03-21'),
                  _divider(colors),
                  _field(l10n.fPlace, _place),
                  _divider(colors),
                  _field(l10n.fOccupation, _occ),
                ]),
                const SizedBox(height: 14),
                _card(colors, [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.hasPassedAway,
                        style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w500,
                            color: colors.ink)),
                    value: _dead,
                    onChanged: (v) => setState(() => _dead = v),
                  ),
                  if (_dead) ...[
                    _divider(colors),
                    _field(l10n.fDied, _died, hint: '1994 or 1994-11-04'),
                    _divider(colors),
                    _field(l10n.fBurial, _burial),
                  ],
                ]),
                const SizedBox(height: 14),
                _card(colors, [_field(l10n.fNote, _note, maxLines: 3)]),
                const SizedBox(height: 22),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.brand,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;
                    final b = FuzzyDate.tryParse(_born.text);
                    final d = _dead ? FuzzyDate.tryParse(_died.text) : null;
                    await (db.update(db.persons)
                          ..where((t) => t.id.equals(widget.personId)))
                        .write(PersonsCompanion(
                      givenName: drift_v(_first.text.trim()),
                      surname: drift_v(_last.text.trim()),
                      gender: drift_v(_gender),
                      birthDate: drift_v(b?.date),
                      birthPrecision: drift_v(b?.precision ?? 'day'),
                      birthPlace: drift_v(_place.text.trim().isEmpty
                          ? null
                          : _place.text.trim()),
                      burialPlace: drift_v(_burial.text.trim().isEmpty
                          ? null
                          : _burial.text.trim()),
                      occupation: drift_v(_occ.text.trim().isEmpty
                          ? null
                          : _occ.text.trim()),
                      note: drift_v(
                          _note.text.trim().isEmpty ? null : _note.text.trim()),
                      isLiving: drift_v(!_dead),
                      deathDate: drift_v(d?.date),
                      deathPrecision: drift_v(d?.precision ?? 'day'),
                      updatedAt: drift_v(DateTime.now()),
                    ));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.personSaved)));
                      context.pop();
                    }
                  },
                  child: Text(l10n.saveChanges,
                      style: const TextStyle(
                          fontSize: 15.5, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.danger,
                    side: BorderSide(color: colors.line2),
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(l10n.deletePerson),
                        content: Text('${_first.text} ${_last.text}'),
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
                    if (ok != true) return;
                    await (db.update(db.persons)
                          ..where((t) => t.id.equals(widget.personId)))
                        .write(PersonsCompanion(
                      deletedAt: drift_v(DateTime.now()),
                      updatedAt: drift_v(DateTime.now()),
                    ));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.personDeleted)));
                      context.pop();
                    }
                  },
                  child: Text(l10n.deletePerson),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // drift Value 包装的简写
  Value<T> drift_v<T>(T v) => Value<T>(v);

  Widget _card(LarariumColors colors, List<Widget> children) => Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.line),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Column(children: children),
      );

  Widget _divider(LarariumColors colors) => Divider(color: colors.line, height: 1);

  Widget _field(String label, TextEditingController controller,
      {String? hint, int maxLines = 1, String? Function(String?)? validator}) {
    final colors = Theme.of(context).extension<LarariumColors>()!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment:
            maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 96,
            child: Text(label,
                style: TextStyle(fontSize: 13, color: colors.ink3)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: controller,
              maxLines: maxLines,
              validator: validator,
              style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w500,
                  color: colors.ink),
              decoration: InputDecoration(hintText: hint, isDense: true),
            ),
          ),
        ],
      ),
    );
  }
}

// 顶部 Photo 按钮（阶段 3 接媒体上传），先占位
