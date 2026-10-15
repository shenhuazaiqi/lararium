import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/cloud_config.dart';
import '../../core/fuzzy_date.dart';
import '../../core/theme.dart';
import '../../data/db/app_database.dart';
import '../../data/db/tables.dart' show newId;
import '../../data/providers.dart';
import 'avatar_crop_screen.dart';
import 'photo_avatar.dart';

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
  final _eventTitle = TextEditingController();
  final _eventDate = TextEditingController();
  bool _uploadingPhotos = false;
  bool _showEventForm = false;
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
    _eventTitle.dispose();
    _eventDate.dispose();
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
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 30),
              children: [
                Center(
                  child: Column(
                    children: [
                      PhotoAvatar(
                          person: person, size: 80, fontSize: 27),
                      const SizedBox(height: 4),
                      TextButton(
                        onPressed: () async {
                          // 媒体上传（阶段 3）：选图 → 裁剪页 → 压缩 → Storage 私密桶
                          try {
                            final picked = await FilePicker.platform.pickFiles(
                              type: FileType.image,
                              withData: false,
                            );
                            if (picked == null || picked.files.isEmpty) return;
                            final path = picked.files.single.path;
                            if (path == null) return;
                            final bytes = await File(path).readAsBytes();
                            if (!mounted) return;
                            final cropped =
                                await AvatarCropScreen.push(context, bytes);
                            if (cropped == null) return;
                            final treeId = ref.read(effectiveTreeIdProvider);
                            if (treeId == null) return;
                            await ref.read(photoServiceProvider).uploadAvatar(
                                  treeId: treeId,
                                  personId: widget.personId,
                                  imageBytes: cropped,
                                );
                            // 头像版本自增 → 树页/头像组件立即重拉
                            // （存储路径固定，路径无变化必须显式通知）
                            ref.read(avatarEpochProvider.notifier).state++;
                            // 触发 provider 重取（头像立即刷新）
                            ref.invalidate(personProvider(widget.personId));
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text(l10n.photoUploaded)));
                            }
                          } catch (e) {
                            // ignore: avoid_print
                            print('PHOTO_UPLOAD_ERR: $e');
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text(l10n.errShare)));
                            }
                          }
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
                const SizedBox(height: 14),
                // 相册
                _albumCard(l10n, colors),
                const SizedBox(height: 14),
                // 大事记（自定义）
                _eventsCard(l10n, colors),
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

  // ---------- 相册 ----------

  Widget _albumCard(AppLocalizations l10n, LarariumColors colors) {
    final mediaAsync = ref.watch(mediaByPersonProvider(widget.personId));
    final media = mediaAsync.value ?? const <PersonMedia>[];
    return _card(colors, [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(l10n.album,
                    style: TextStyle(
                        fontSize: 13, color: colors.ink3)),
                const Spacer(),
                if (_uploadingPhotos)
                  const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2)),
              ],
            ),
            const SizedBox(height: 10),
            if (media.isEmpty && !_uploadingPhotos)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(l10n.writeMessage,
                    style: TextStyle(fontSize: 13, color: colors.ink3)),
              ),
            if (media.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final m in media)
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: _albumImage(m, size: 86),
                        ),
                        Positioned(
                          top: 2,
                          right: 2,
                          child: GestureDetector(
                            onTap: () => _deleteAlbumPhoto(m),
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.55),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close,
                                  size: 13, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: OutlinedButton.icon(
                onPressed: _uploadingPhotos ? null : _addAlbumPhotos,
                icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
                label: Text(l10n.addPhoto, style: const TextStyle(fontSize: 13.5)),
              ),
            ),
          ],
        ),
      ),
    ]);
  }

  /// 相册图：本地副本优先，缺失时走 Storage 公开对象 URL
  Widget _albumImage(PersonMedia m, {required double size}) {
    Widget img;
    if (m.localPath != null && File(m.localPath!).existsSync()) {
      img = Image.file(File(m.localPath!),
          width: size, height: size, fit: BoxFit.cover, gaplessPlayback: true);
    } else if (m.storagePath != null) {
      final url =
          '${CloudConfig.supabaseUrl}/storage/v1/object/person-album/${m.storagePath!}';
      img = Image.network(url,
          width: size, height: size, fit: BoxFit.cover, errorBuilder:
              (context, error, stack) => Container(
                  width: size,
                  height: size,
                  color: colors_bg(context),
                  child: const Icon(Icons.image_outlined)));
    } else {
      img = Container(width: size, height: size, color: colors_bg(context));
    }
    return SizedBox(width: size, height: size, child: img);
  }

  Color colors_bg(BuildContext context) =>
      Theme.of(context).colorScheme.surfaceContainerHighest;

  Future<void> _addAlbumPhotos() async {
    final picked = await FilePicker.platform
        .pickFiles(type: FileType.image, allowMultiple: true, withData: false);
    if (picked == null || picked.files.isEmpty) return;
    final treeId = ref.read(effectiveTreeIdProvider);
    if (treeId == null) return;
    setState(() => _uploadingPhotos = true);
    final db = ref.read(databaseProvider);
    final client = Supabase.instance.client;
    try {
      final docDir = await getApplicationDocumentsDirectory();
      for (final f in picked.files) {
        if (f.path == null) continue;
        final mediaId = newId();
        final path = 'tree_$treeId/person_${widget.personId}/$mediaId.jpg';
        final raw = await File(f.path!).readAsBytes();
        final compressed = await FlutterImageCompress.compressWithList(raw,
            minWidth: 1280, minHeight: 1280, quality: 82,
            format: CompressFormat.jpeg);
        final localPath = p.join(docDir.path, 'album_$mediaId.jpg');
        await File(localPath).writeAsBytes(compressed);
        await client.storage.from('person-album').uploadBinary(
              path,
              compressed,
              fileOptions: const FileOptions(
                  upsert: true, contentType: 'image/jpeg'),
            );
        await (db.into(db.personMedias)).insert(PersonMediasCompanion.insert(
          id: Value(mediaId),
          treeId: treeId,
          personId: widget.personId,
          storagePath: Value(path),
          localPath: Value(localPath),
        ));
      }
    } catch (_) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.errShare)));
      }
    } finally {
      if (mounted) setState(() => _uploadingPhotos = false);
    }
  }

  Future<void> _deleteAlbumPhoto(PersonMedia m) async {
    final db = ref.read(databaseProvider);
    await (db.update(db.personMedias)..where((x) => x.id.equals(m.id))).write(
      PersonMediasCompanion(
          deletedAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now())),
    );
    try {
      final client = Supabase.instance.client;
      if (m.storagePath != null) {
        await client.storage.from('person-album').remove([m.storagePath!]);
      }
      await client.from('media').delete().eq('id', m.id);
    } catch (_) {}
  }

  // ---------- 大事记（自定义） ----------

  Widget _eventsCard(AppLocalizations l10n, LarariumColors colors) {
    final eventsAsync = ref.watch(eventsByPersonProvider(widget.personId));
    final events = eventsAsync.value ?? const <PersonEvent>[];
    final sorted = [...events]..sort((a, b) => a.eventDate.compareTo(b.eventDate));
    return _card(colors, [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.timeline,
                style: TextStyle(fontSize: 13, color: colors.ink3)),
            const SizedBox(height: 10),
            if (sorted.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(l10n.writeMessage,
                    style: TextStyle(fontSize: 13, color: colors.ink3)),
              ),
            for (final e in sorted)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 86,
                      child: Text(
                          FuzzyDate.encode(e.eventDate, e.datePrecision),
                          style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: colors.brand)),
                    ),
                    Expanded(
                      child: Text(e.title,
                          style: TextStyle(
                              fontSize: 14, color: colors.ink)),
                    ),
                    GestureDetector(
                      onTap: () => _deleteEvent(e),
                      child: Icon(Icons.close,
                          size: 16, color: colors.ink3),
                    ),
                  ],
                ),
              ),
            if (_showEventForm) ...[
              Divider(color: colors.line, height: 1),
              const SizedBox(height: 8),
              _field(l10n.eventTitle, _eventTitle),
              _field(l10n.fBorn, _eventDate, hint: '1994 or 1994-11-04'),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _addEvent,
                  child: Text(l10n.saveChanges),
                ),
              ),
            ],
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: OutlinedButton.icon(
                onPressed: () =>
                    setState(() => _showEventForm = !_showEventForm),
                icon: const Icon(Icons.add_circle_outline, size: 18),
                label: Text(l10n.addEvent,
                    style: const TextStyle(fontSize: 13.5)),
              ),
            ),
          ],
        ),
      ),
    ]);
  }

  Future<void> _addEvent() async {
    final title = _eventTitle.text.trim();
    final d = FuzzyDate.tryParse(_eventDate.text.trim());
    if (title.isEmpty || d == null) return;
    final treeId = ref.read(effectiveTreeIdProvider);
    if (treeId == null) return;
    final db = ref.read(databaseProvider);
    await (db.into(db.personEventsTable)).insert(PersonEventsTableCompanion.insert(
      id: Value(newId()),
      treeId: treeId,
      personId: widget.personId,
      title: title,
      eventDate: d.date,
      datePrecision: Value(d.precision),
    ));
    _eventTitle.clear();
    _eventDate.clear();
    setState(() => _showEventForm = false);
  }

  Future<void> _deleteEvent(PersonEvent e) async {
    final db = ref.read(databaseProvider);
    await (db.update(db.personEventsTable)..where((x) => x.id.equals(e.id))).write(
      PersonEventsTableCompanion(
          deletedAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now())),
    );
    try {
      await Supabase.instance.client
          .from('events')
          .delete()
          .eq('id', e.id);
    } catch (_) {}
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
