import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/fuzzy_date.dart';
import '../../core/theme.dart';
import '../../data/db/app_database.dart';
import '../../data/db/tables.dart' show newId;
import '../../data/providers.dart';

/// 创建树的第一个人（空树场景）：自己或任意祖先起步。
/// 若当前树没有任何人，新建者自动成为焦点人物（isSelf）。
class PersonCreateScreen extends ConsumerStatefulWidget {
  const PersonCreateScreen({super.key});

  @override
  ConsumerState<PersonCreateScreen> createState() => _PersonCreateScreenState();
}

class _PersonCreateScreenState extends ConsumerState<PersonCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _born = TextEditingController();
  String _gender = 'unknown';
  bool _busy = false;

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    _born.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<LarariumColors>()!;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        title: Text(l10n.personNew,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 30),
          children: [
            _card(colors, [
              _field(l10n.fFirst, _first,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? l10n.errEnterFirstName
                      : null),
              _divider(colors),
              _field(l10n.fLast, _last),
            ]),
            const SizedBox(height: 14),
            _card(colors, [
              _field(l10n.fBorn, _born, hint: '1900 or 1900-03-21'),
            ]),
            const SizedBox(height: 14),
            _card(colors, [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Wrap(
                  spacing: 8,
                  children: [
                    for (final (code, label) in [
                      ('male', l10n.genderMale),
                      ('female', l10n.genderFemale),
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
                            fontWeight: FontWeight.w600),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9)),
                        side: BorderSide(
                            color: _gender == code
                                ? colors.brand
                                : colors.line2),
                      ),
                  ],
                ),
              ),
            ]),
            const SizedBox(height: 22),
            SizedBox(
              height: 50,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: colors.brand,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _busy ? null : _save,
                child: Text(l10n.save,
                    style: const TextStyle(
                        fontSize: 15.5, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final treeId = ref.read(effectiveTreeIdProvider);
    if (treeId == null) return;
    setState(() => _busy = true);
    final db = ref.read(databaseProvider);
    final b = FuzzyDate.tryParse(_born.text);
    final l10n = AppLocalizations.of(context);

    final existing = await (db.select(db.persons)
          ..where((p) => p.treeId.equals(treeId) & p.deletedAt.isNull()))
        .get();
    final isFirst = existing.isEmpty;

    await db.into(db.persons).insert(PersonsCompanion.insert(
          id: Value(newId()),
          treeId: treeId,
          givenName: Value(_first.text.trim()),
          surname: Value(_last.text.trim()),
          gender: Value(_gender),
          birthDate: Value(b?.date),
          birthPrecision: Value(b?.precision ?? 'day'),
          isSelf: Value(isFirst), // 树的第一个人 = 焦点
        ));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.personSaved)));
      context.pop();
    }
  }

  Widget _card(LarariumColors colors, List<Widget> children) => Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.line),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Column(children: children),
      );

  Widget _divider(LarariumColors colors) =>
      Divider(color: colors.line, height: 1);

  Widget _field(String label, TextEditingController controller,
      {String? hint, String? Function(String?)? validator}) {
    final colors = Theme.of(context).extension<LarariumColors>()!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          SizedBox(
              width: 96,
              child:
                  Text(label, style: TextStyle(fontSize: 13, color: colors.ink3))),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: controller,
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
