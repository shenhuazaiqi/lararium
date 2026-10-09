import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme.dart';
import '../../data/providers.dart';
import '../../data/sync_service.dart' show SyncPhase;

/// 08 同步与共享：登录 / 同步状态 / 邀请链接。
class SyncScreen extends ConsumerStatefulWidget {
  const SyncScreen({super.key});

  @override
  ConsumerState<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends ConsumerState<SyncScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _signUpMode = false;
  bool _busy = false;
  bool _syncing = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _auth() async {
    final l10n = AppLocalizations.of(context);
    final service = ref.read(syncServiceProvider);
    setState(() => _busy = true);
    try {
      if (_signUpMode) {
        await service.signUp(_email.text.trim(), _password.text);
      } else {
        await service.signIn(_email.text.trim(), _password.text);
      }
      ref.read(authEmailProvider.notifier).state = service.currentEmail;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.allSynced)));
        _sync();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.syncError)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _signOut() async {
    final service = ref.read(syncServiceProvider);
    await service.signOut();
    ref.read(authEmailProvider.notifier).state = null;
  }

  Future<void> _sync() async {
    final treeId = ref.read(effectiveTreeIdProvider);
    if (treeId == null || _syncing) return;
    final l10n = AppLocalizations.of(context);
    final service = ref.read(syncServiceProvider);
    setState(() => _syncing = true);
    ref.read(syncStatusProvider.notifier).state =
        ref.read(syncStatusProvider).copyWith(phase: SyncPhase.pushing);
    try {
      final status = await service.syncTree(treeId);
      ref.read(syncStatusProvider.notifier).state = status;
      final prefs = ref.read(prefsProvider);
      await prefs.setString(
          'last_sync_at', (status.lastSyncAt ?? DateTime.now()).toIso8601String());
      if (mounted) {
        final msg = status.pulled > 0
            ? l10n.syncPulled(status.pulled)
            : l10n.syncPushed(status.pushed);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (e) {
      ref.read(syncStatusProvider.notifier).state = ref
          .read(syncStatusProvider)
          .copyWith(phase: SyncPhase.error, error: '$e');
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.syncError)));
      }
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<LarariumColors>()!;
    final l10n = AppLocalizations.of(context);
    final email = ref.watch(authEmailProvider);
    final syncStatus = ref.watch(syncStatusProvider);
    final prefs = ref.watch(prefsProvider);
    final lastSyncStr = prefs.getString('last_sync_at');
    final lastSync = lastSyncStr == null
        ? null
        : DateTime.tryParse(lastSyncStr);

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        title: Text(l10n.syncTitle,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 30),
        children: [
          // --- 同步状态卡 ---
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colors.brandSoft,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: _syncing
                      ? const Padding(
                          padding: EdgeInsets.all(8),
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : Icon(Icons.check, color: colors.brand, size: 18),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        syncStatus.phase == SyncPhase.error
                            ? l10n.syncError
                            : l10n.allSynced,
                        style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w600,
                            color: colors.brand),
                      ),
                      if (lastSync != null)
                        Text(l10n.lastSync(_fmtTime(lastSync)),
                            style: TextStyle(
                                fontSize: 12.5, color: colors.ink3)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // --- 账号卡 ---
          Text(l10n.authCardTitle.toUpperCase(),
              style: TextStyle(
                  fontSize: 12.5,
                  letterSpacing: 0.6,
                  fontWeight: FontWeight.w700,
                  color: colors.ink3)),
          const SizedBox(height: 9),
          if (email == null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.authNeedAccount,
                      style: TextStyle(
                          fontSize: 13.5, height: 1.5, color: colors.ink2)),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(fontSize: 14.5, color: colors.ink),
                    decoration:
                        InputDecoration(hintText: l10n.email, isDense: true),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _password,
                    obscureText: true,
                    style: TextStyle(fontSize: 14.5, color: colors.ink),
                    decoration: InputDecoration(
                        hintText:
                            _signUpMode ? l10n.passwordHint : l10n.password,
                        isDense: true),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: colors.brand,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _busy ? null : _auth,
                      child: Text(_signUpMode ? l10n.signUp : l10n.signIn),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton(
                      onPressed: () =>
                          setState(() => _signUpMode = !_signUpMode),
                      child: Text(
                          _signUpMode
                              ? l10n.authSwitchToSignIn
                              : l10n.authSwitchToSignUp,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: colors.brand)),
                    ),
                  ),
                ],
              ),
            )
          else
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
                    radius: 20,
                    backgroundColor: colors.brandSoft,
                    child: Text(
                      email.characters.first.toUpperCase(),
                      style: TextStyle(
                          color: colors.brand,
                          fontWeight: FontWeight.w600,
                          fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.authSignedInAs(email),
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: colors.ink)),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: _signOut,
                    child: Text(l10n.signOut,
                        style: TextStyle(color: colors.danger)),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 14),

          // --- 立即同步 ---
          SizedBox(
            height: 50,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: colors.brand,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              icon: _syncing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.sync, size: 18),
              label: Text(l10n.syncNow,
                  style: const TextStyle(
                      fontSize: 15.5, fontWeight: FontWeight.w600)),
              onPressed: email == null || _syncing ? null : _sync,
            ),
          ),
          const SizedBox(height: 14),

          // --- 成员与邀请 ---
          Text(l10n.membersSection.toUpperCase(),
              style: TextStyle(
                  fontSize: 12.5,
                  letterSpacing: 0.6,
                  fontWeight: FontWeight.w700,
                  color: colors.ink3)),
          const SizedBox(height: 9),
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
                  radius: 18,
                  backgroundColor: colors.brandSoft,
                  child: Icon(Icons.person_outline,
                      size: 20, color: colors.brand),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    email == null ? l10n.authNeedAccount : email,
                    style:
                        TextStyle(fontSize: 14, color: colors.ink),
                  ),
                ),
                Text(l10n.currentTag,
                    style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: colors.ink3)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: colors.ink,
              side: BorderSide(color: colors.line2),
              minimumSize: const Size.fromHeight(48),
            ),
            icon: const Icon(Icons.link, size: 18),
            label: Text(l10n.copyInvite),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.memorialLinkCopied)));
            },
          ),
          const SizedBox(height: 14),
          Center(
            child: Text(l10n.offlineQueueNote,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 11.5, height: 1.6, color: colors.ink4)),
          ),
        ],
      ),
    );
  }

  String _fmtTime(DateTime t) =>
      '${t.year}-${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')} ${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}
