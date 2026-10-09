import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../data/providers.dart';
import '../../data/repositories/family_service.dart';

/// 11 添加亲属：先选关系，姓自动继承，名必填校验。
class AddRelativeScreen extends ConsumerStatefulWidget {
  const AddRelativeScreen({
    super.key,
    required this.baseId,
    this.initialRel = 'parent',
  });

  final String baseId;
  final String initialRel;

  @override
  ConsumerState<AddRelativeScreen> createState() => _AddRelativeScreenState();
}

class _AddRelativeScreenState extends ConsumerState<AddRelativeScreen> {
  final _first = TextEditingController();
  final _last = TextEditingController();
  late RelKind _rel;
  bool _prefilled = false;

  @override
  void initState() {
    super.initState();
    _rel = switch (widget.initialRel) {
      'spouse' => RelKind.spouse,
      'child' => RelKind.child,
      'sibling' => RelKind.sibling,
      _ => RelKind.parent,
    };
  }

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final personAsync = ref.watch(personProvider(widget.baseId));
    final colors = Theme.of(context).extension<LarariumColors>()!;
    final l10n = AppLocalizations.of(context);
    final service = ref.watch(familyServiceProvider);
    final treeId = ref.watch(defaultTreeProvider).value?.id;

    if (treeId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        title: Text(l10n.addTitle,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
      ),
      body: personAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (base) {
          if (base == null) return const Center(child: Text('—'));
          if (!_prefilled) {
            _last.text = base.surname;
            _prefilled = true;
          }
          final rels = [
            (RelKind.parent, l10n.relParent, l10n.relParentHint),
            (RelKind.spouse, l10n.relSpouse, l10n.relSpouseHint),
            (RelKind.child, l10n.relChild, l10n.relChildHint),
            (RelKind.sibling, l10n.relSibling, l10n.relSiblingHint),
          ];
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 30),
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.line),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: colors.brandSoft,
                      child: Text(
                        ((base.givenName.isNotEmpty ? base.givenName[0] : '')).toUpperCase(),
                        style: TextStyle(
                            color: colors.brand, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${base.givenName} ${base.surname}'.trim(),
                              style: TextStyle(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w600,
                                  color: colors.ink)),
                          Text(l10n.addWho,
                              style: TextStyle(
                                  fontSize: 12.5, color: colors.ink3)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              ...rels.map((r) {
                final selected = _rel == r.$1;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Material(
                    color: selected ? colors.brandSoft : colors.surface,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => setState(() => _rel = r.$1),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: selected ? colors.brand : colors.line,
                              width: 1.5),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    selected ? colors.brand : Colors.transparent,
                                border: Border.all(
                                    color:
                                        selected ? colors.brand : colors.line2,
                                    width: 1.5),
                              ),
                              child: selected
                                  ? const Icon(Icons.check,
                                      size: 12, color: Colors.white)
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(r.$2,
                                      style: TextStyle(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w600,
                                          color: colors.ink)),
                                  Text(r.$3,
                                      style: TextStyle(
                                          fontSize: 12, color: colors.ink3)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 14),
              Container(
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.line),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Column(
                  children: [
                    _row(l10n.fFirst, _first, colors),
                    Divider(color: colors.line, height: 1),
                    _row(l10n.fLast, _last, colors),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: colors.brand,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () async {
                  final name = _first.text.trim();
                  if (name.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.errEnterFirstName)));
                    return;
                  }
                  await service.addRelative(
                    treeId: treeId,
                    base: base,
                    kind: _rel,
                    givenName: name,
                    surname: _last.text.trim(),
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(l10n.addedToTree('$name ${_last.text.trim()}'
                            .trim()))));
                    context.pop();
                  }
                },
                child: Text(l10n.saveChanges,
                    style: const TextStyle(
                        fontSize: 15.5, fontWeight: FontWeight.w600)),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _row(String label, TextEditingController c, LarariumColors colors) {
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
            child: TextField(
              controller: c,
              style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w500,
                  color: colors.ink),
              decoration: const InputDecoration(
                  hintText: '—', isDense: true, border: InputBorder.none),
            ),
          ),
        ],
      ),
    );
  }
}
