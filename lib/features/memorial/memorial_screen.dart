import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../data/db/app_database.dart';
import '../../data/providers.dart';
import 'fx_stage.dart';
import 'memorial_quota.dart';
import 'memorial_theme_defs.dart';

/// 05 纪念页 —— 核心情感差异化（规划文档 5.4）。
/// v4 交互：动作两步确认（选中 → 舞台预览 → Send 才计数），杜绝误触。
class MemorialScreen extends ConsumerStatefulWidget {
  const MemorialScreen({super.key, required this.personId});

  final String personId;

  @override
  ConsumerState<MemorialScreen> createState() => _MemorialScreenState();
}

class _MemorialScreenState extends ConsumerState<MemorialScreen> {
  String? _pendingAct; // 已选中、待发送
  String? _sentAct; // 本会话已发送
  bool _pickerShown = false;

  int _countFor(Person p, String actKey) => switch (actKey) {
        'flower' || 'marigold' || 'garland' => p.flowerCount,
        'candle' || 'diya' || 'ofrenda' || 'stone' => p.candleCount,
        'incense' => p.incenseCount,
        'prayer' || 'bow' || 'donation' => p.prayerCount,
        'memory' => p.messageCount,
        _ => 0,
      };

  String? _dbCountField(String actKey) => switch (actKey) {
        'flower' || 'marigold' || 'garland' => 'flower',
        'candle' || 'diya' || 'ofrenda' || 'stone' => 'candle',
        'incense' => 'incense',
        'prayer' || 'bow' || 'donation' => 'prayer',
        _ => null, // memory → 留言数由留言表驱动
      };

  @override
  Widget build(BuildContext context) {
    final personAsync = ref.watch(personProvider(widget.personId));
    final colors = Theme.of(context).extension<LarariumColors>()!;
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);

    return personAsync.when(
      loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('$e'))),
      data: (person) {
        if (person == null) {
          return Scaffold(body: Center(child: Text(l10n.searchEmpty)));
        }
        final p = person;
        final themeKey = p.memorialTheme ??
            resolveRegionTheme(locale);
        final theme = themeByKey(themeKey);
        final localeTag = locale.toString();

        // 首次进入：未选过主题 → 弹一次确认层（规划文档 5.4.3-C 关键 UX）
        if (p.memorialTheme == null && !_pickerShown) {
          _pickerShown = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _openThemePicker();
          });
        }

        return Scaffold(
          backgroundColor: colors.bg,
          body: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _hero(p, localeTag, colors),
                    Transform.translate(
                      offset: const Offset(0, -34),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: colors.line),
                          ),
                          child: Column(
                            children: [
                              Text(l10n.inLovingMemory.toUpperCase(),
                                  style: TextStyle(
                                      fontSize: 11,
                                      letterSpacing: 1,
                                      fontWeight: FontWeight.w700,
                                      color: colors.ink3)),
                              if (p.epitaph?.isNotEmpty ?? false) ...[
                                const SizedBox(height: 7),
                                Text('“${p.epitaph ?? ''}”',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 13.5,
                                        height: 1.55,
                                        fontStyle: FontStyle.italic,
                                        color: colors.ink2)),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 2, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: _styleChip(theme, l10n, colors),
                          ),
                          const SizedBox(height: 16),
                          // 动作栏（按主题包过滤）
                          Row(
                            children: [
                              for (var i = 0;
                                  i < theme.acts.length;
                                  i++) ...[
                                if (i > 0) const SizedBox(width: 8),
                                Expanded(
                                  child: _actButton(theme.acts[i], p, l10n,
                                      theme, colors),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 14),
                          FxStage(
                            kind: _pendingAct != null
                                ? _fxOf(theme, _pendingAct!)
                                : (_sentAct != null
                                    ? _fxOf(theme, _sentAct!)
                                    : null),
                            theme: theme,
                            hint: _sentAct != null
                                ? l10n.tributeOffered
                                : _pendingAct != null
                                    ? l10n.tributeArmed
                                    : l10n.chooseTribute,
                          ),
                          const SizedBox(height: 10),
                          _sendButton(theme, l10n, colors),
                          const SizedBox(height: 22),
                          _messages(p, l10n, colors, localeTag),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: _sharePublic,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: colors.ink,
                              side: BorderSide(color: colors.line2),
                              minimumSize: const Size.fromHeight(50),
                            ),
                            icon: const Icon(Icons.ios_share, size: 18),
                            label: Text(l10n.shareMemorial),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            '${l10n.familyOnlyNote}\n${l10n.anniversaryNote(anniversaryLabel(p, localeTag))}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 11.5,
                                height: 1.6,
                                color: colors.ink4),
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              _composer(p, l10n, colors),
            ],
          ),
        );
      },
    );
  }

  String _fxOf(MemorialThemeDef theme, String actKey) =>
      theme.acts.firstWhere((a) => a.key == actKey, orElse: () => theme.acts.first).fx;

  // ---------- hero ----------

  Widget _hero(Person p, String localeTag, LarariumColors colors) {
    final born = p.birthDate == null
        ? ''
        : formatFuzzyDate(p.birthDate!, p.birthPrecision, localeTag);
    final died = p.deathDate == null
        ? ''
        : formatFuzzyDate(p.deathDate!, p.deathPrecision, localeTag);
    final dates = [
      if (born.isNotEmpty) born,
      if (died.isNotEmpty) died,
    ].join(' – ');
    return Container(
      height: 214,
      color: colors.surface,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0, 0.44, 1],
                colors: [Color(0xFF211D28), Color(0xFF3A3040), Color(0xFF6B5568)],
              ),
            ),
          ),
          // 暖光
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.55),
                radius: 1.1,
                colors: [
                  const Color(0xFFFFD6A0).withOpacity( 0.18),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          // 壁龛拱形（Lararium 品牌呼应）
          Center(
            child: Container(
              width: 104,
              height: 96,
              margin: const EdgeInsets.only(bottom: 60),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(52)),
                border: Border.all(
                    color: const Color(0xFFECECCE).withOpacity(0.16)),
              ),
              child: Align(
                alignment: Alignment(0, 0.9),
                child: Container(
                  width: 30,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      center: const Alignment(0, 0.5),
                      radius: 0.9,
                      colors: [
                        const Color(0xFFCD8A8A).withOpacity( 0.38),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // 底部渐隐
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 106,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [colors.bg.withOpacity( 0), colors.bg],
                ),
              ),
            ),
          ),
          // 返回
          Positioned(
            top: 44,
            left: 12,
            child: _circleBtn(context, Icons.arrow_back, () => context.pop()),
          ),
          // 姓名 + 生卒
          Positioned(
            left: 20,
            right: 20,
            bottom: 48,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${p.givenName} ${p.surname}'.trim(),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5)),
                const SizedBox(height: 4),
                Text(dates,
                    style: TextStyle(
                        color: Colors.white.withOpacity( 0.8),
                        fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleBtn(BuildContext context, IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.black.withOpacity( 0.32),
      shape: const CircleBorder(
          side: BorderSide(color: Colors.white24)),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(icon, size: 18, color: Colors.white),
        ),
      ),
    );
  }

  Widget _styleChip(
      MemorialThemeDef theme, AppLocalizations l10n, LarariumColors colors) {
    return Material(
      color: colors.surface2,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: _openThemePicker,
        child: Container(
          padding: const EdgeInsets.fromLTRB(11, 6, 13, 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colors.line),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  for (var i = 0; i < theme.swatches.length; i++)
                    Transform.translate(
                      offset: Offset(i == 0 ? 0 : -3.5, 0),
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.swatches[i],
                          border: Border.all(
                              color: colors.surface2, width: 1.5),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 8),
              Text(theme.label(l10n),
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: theme.accent)),
              Icon(Icons.expand_more,
                  size: 14, color: colors.ink4),
            ],
          ),
        ),
      ),
    );
  }

  void _openThemePicker() {
    context.push('/settings/memorial-style?person=${widget.personId}');
  }

  // ---------- 动作 ----------

  Widget _actButton(TributeActionDef act, Person p, AppLocalizations l10n,
      MemorialThemeDef theme, LarariumColors colors) {
    final selected = _pendingAct == act.key;
    final iconFor = switch (act.key) {
      'flower' || 'garland' => Icons.local_florist,
      'marigold' => Icons.filter_vintage,
      'candle' || 'diya' => Icons.light_mode_outlined,
      'incense' => Icons.air,
      'prayer' => Icons.self_improvement,
      'bow' => Icons.south,
      'stone' => Icons.landscape,
      'ofrenda' => Icons.card_giftcard,
      'donation' => Icons.favorite_outline,
      'memory' => Icons.photo_library_outlined,
      _ => Icons.local_florist,
    };
    return Material(
      color: selected ? theme.soft : colors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          setState(() {
            _pendingAct = act.key;
            _sentAct = null;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: selected ? theme.accent : colors.line),
          ),
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(iconFor,
                      size: 22,
                      color: selected ? theme.accent : colors.ink2),
                  Positioned(
                    top: -7,
                    right: -11,
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 17),
                      height: 15,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected ? theme.accent : colors.surface2,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('${_countFor(p, act.key)}',
                          style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color:
                                  selected ? Colors.white : colors.ink2)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              Text(actLabel(l10n, act.key),
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: selected ? theme.accent : colors.ink3)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sendButton(
      MemorialThemeDef theme, AppLocalizations l10n, LarariumColors colors) {
    final sent = _sentAct != null;
    final enabled = _pendingAct != null && !sent;
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: FilledButton.icon(
        onPressed: enabled ? () => _send() : null,
        style: FilledButton.styleFrom(
          backgroundColor: sent ? theme.soft : theme.accent,
          foregroundColor: sent ? theme.accent : Colors.white,
          disabledBackgroundColor:
              sent ? theme.soft : colors.surface2,
          disabledForegroundColor: sent ? theme.accent : colors.ink4,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
        icon: sent
            ? null
            : const Icon(Icons.favorite, size: 16),
        label: Text(
          sent
              ? l10n.sentDone
              : _pendingAct != null
                  ? actSendLabel(l10n, _pendingAct!)
                  : l10n.chooseTribute,
          style: const TextStyle(
              fontSize: 14.5, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  /// 分享公开纪念页（5.4.2）：首次分享先征询 → 开启 allow_public_link → 分享链接。
  Future<void> _sharePublic() async {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).extension<LarariumColors>()!;
    final db = ref.read(databaseProvider);
    final person = ref.read(personProvider(widget.personId)).value;
    if (person == null) return;

    if (!person.allowPublicLink) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.sharePublicTitle),
          content: Text(l10n.sharePublicBody),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(l10n.cancel)),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: colors.brand),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.sharePublicEnable),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
      // 本地 + 云端同步开启
      await (db.update(db.persons)..where((t) => t.id.equals(person.id)))
          .write(PersonsCompanion(allowPublicLink: Value(true)));
      try {
        await Supabase.instance.client
            .from('memorial_profiles')
            .update({'allow_public_link': true})
            .eq('person_id', person.id);
      } catch (_) {
        // 未登录/离线：本地已开启，下次同步补写
      }
    }

    // 公开纪念页托管在 GitHub Pages（用户自选方案：网页不买服务器），
    // 页面用 anon RPC 读取受限字段，Supabase Edge Function 沙箱策略不适用于静态托管。
    const publicMemorialBase =
        'https://shenhuazaiqi.github.io/lararium/memorial.html';
    final url = '$publicMemorialBase?p=${person.id}';
    final years = personYears(person);
    try {
      // gen-l10n 占位符按字母序生成参数：{name}, {url}, {years}
      await Share.share(l10n.shareText(
        '${person.givenName} ${person.surname}'.trim(),
        url,
        years.isEmpty ? 'In Loving Memory' : years,
      ));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.errShare)));
      }
    }
  }

  Future<void> _send() async {
    final act = _pendingAct;
    if (act == null) return;
    // 免费额度（5.4.4）：各 1 次/天，忌日当天 +1；温和拒绝 + 免费出口
    final prefs = ref.read(prefsProvider);
    final person = ref.read(personProvider(widget.personId)).value;
    final quota = MemorialQuota.check(
      prefs,
      widget.personId,
      act,
      person?.deathDate,
    );
    if (!quota.allowed) {
      if (!mounted) return;
      final sheetColors = Theme.of(context).extension<LarariumColors>()!;
      showModalBottomSheet(
        context: context,
        builder: (ctx) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 8, 22, 26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.favorite_outline,
                    size: 36, color: themeByKey(null).accent),
                const SizedBox(height: 12),
                Text(AppLocalizations.of(context).quotaExhaustedTitle,
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: sheetColors.ink)),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context).quotaExhaustedBody,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 13.5, height: 1.6, color: sheetColors.ink2),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                        backgroundColor: sheetColors.brand),
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: Text(AppLocalizations.of(context).quotaMessageFree),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      return;
    }
    await MemorialQuota.consume(prefs, widget.personId, act);
    final db = ref.read(databaseProvider);
    final field = _dbCountField(act);
    final p = ref.read(personProvider(widget.personId)).value;
    if (p != null && field != null) {
      final next = _countFor(p, act) + 1;
      await (db.update(db.persons)..where((t) => t.id.equals(p.id))).write(
        PersonsCompanion(
          flowerCount: Value(field == 'flower' ? next : p.flowerCount),
          candleCount: Value(field == 'candle' ? next : p.candleCount),
          incenseCount: Value(field == 'incense' ? next : p.incenseCount),
          prayerCount: Value(field == 'prayer' ? next : p.prayerCount),
          lastMemorialAt: Value(DateTime.now()),
        ),
      );
    } else {
      await (db.update(db.persons)..where((t) => t.id.equals(widget.personId)))
          .write(PersonsCompanion(lastMemorialAt: Value(DateTime.now())));
    }
    setState(() => _sentAct = act);
  }

  // ---------- 留言 ----------

  Widget _messages(Person p, AppLocalizations l10n, LarariumColors colors,
      String localeTag) {
    final msgsAsync = ref.watch(messagesProvider(p.id));
    final msgs = msgsAsync.value ?? const <MemorialMessage>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${l10n.messagesSection.toUpperCase()} · ${msgs.length}',
            style: TextStyle(
                fontSize: 12.5,
                letterSpacing: 0.6,
                fontWeight: FontWeight.w700,
                color: colors.ink3)),
        const SizedBox(height: 9),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.line),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: msgs.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: Center(
                      child: Text(l10n.writeMessage,
                          style: TextStyle(
                              fontSize: 13.5, color: colors.ink3))),
                )
              : Column(
                  children: [
                    for (var i = 0; i < msgs.length; i++) ...[
                      if (i > 0) Divider(color: colors.line, height: 1),
                      _messageRow(msgs[i], l10n, colors),
                    ],
                  ],
                ),
        ),
      ],
    );
  }

  Widget _messageRow(
      MemorialMessage m, AppLocalizations l10n, LarariumColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 17,
            backgroundColor: colors.brandSoft,
            child: Text(
              m.authorName.isEmpty
                  ? '?'
                  : m.authorName[0].toUpperCase(),
              style:
                  TextStyle(fontSize: 12, color: colors.brand, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m.authorName,
                    style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: colors.ink)),
                const SizedBox(height: 3),
                Text(m.body,
                    style: TextStyle(
                        fontSize: 14, height: 1.5, color: colors.ink2)),
                const SizedBox(height: 7),
                GestureDetector(
                  onTap: () => _toggleLike(m),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        m.likedByMe ? Icons.favorite : Icons.favorite_border,
                        size: 14,
                        color: m.likedByMe ? colors.danger : colors.ink3,
                      ),
                      const SizedBox(width: 4),
                      Text('${m.likeCount}',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: colors.ink3)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleLike(MemorialMessage m) async {
    final db = ref.read(databaseProvider);
    await (db.update(db.memorialMessages)..where((t) => t.id.equals(m.id)))
        .write(MemorialMessagesCompanion(
      likedByMe: Value(!m.likedByMe),
      likeCount: Value(m.likeCount + (m.likedByMe ? -1 : 1)),
    ));
  }

  // ---------- 底部输入 ----------

  Widget _composer(Person p, AppLocalizations l10n, LarariumColors colors) {
    final controller = TextEditingController();
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.line)),
      ),
      padding: const EdgeInsets.fromLTRB(14, 11, 14, 11),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: colors.brand,
            child: Text(
              l10n.selfBadge.characters.first.toUpperCase(),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: TextField(
              controller: controller,
              style: TextStyle(fontSize: 14, color: colors.ink),
              decoration: InputDecoration(
                hintText: l10n.writeMessage,
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
              ),
              onSubmitted: (_) => _send2(controller, p),
            ),
          ),
          const SizedBox(width: 9),
          Material(
            color: colors.brand,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => _send2(controller, p),
              child: const SizedBox(
                width: 40,
                height: 40,
                child: Icon(Icons.send, size: 17, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _send2(TextEditingController controller, Person p) async {
    final text = controller.text.trim();
    if (text.isEmpty) return;
    // 留言额度：3 条/天（忌日 +1）
    final prefs = ref.read(prefsProvider);
    final mq = MemorialQuota.check(
      prefs,
      p.id,
      'message',
      p.deathDate,
      limit: MemorialQuota.dailyMessageLimit,
    );
    if (!mq.allowed) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context).quotaMessageFree)));
      return;
    }
    await MemorialQuota.consume(prefs, p.id, 'message');
    final db = ref.read(databaseProvider);
    final treeId = ref.read(defaultTreeProvider).value?.id;
    await db.into(db.memorialMessages).insert(MemorialMessagesCompanion.insert(
          treeId: treeId ?? '',
          personId: p.id,
          authorName: 'You', // 登录后在阶段 3 换成真实账号名
          body: text,
        ));
    await (db.update(db.persons)..where((t) => t.id.equals(p.id))).write(
      PersonsCompanion(lastMemorialAt: Value(DateTime.now())),
    );
    controller.clear();
  }
}
