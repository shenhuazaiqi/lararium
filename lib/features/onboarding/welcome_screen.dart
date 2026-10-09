import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../data/providers.dart';

/// 00 欢迎页：免注册引导，本地优先的第一触点。
class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<LarariumColors>()!;
    final l10n = AppLocalizations.of(context);
    final prefs = ref.read(prefsProvider);

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(26, 64, 26, 34),
          child: Column(
            children: [
              const Spacer(),
              // 壁龛 logo：拱形 + 烛光（Lararium）
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(48), bottom: Radius.circular(24)),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF2E6B4F), Color(0xFF1B4433)],
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 40,
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20)),
                      border: Border.all(
                          color: Colors.white.withOpacity( 0.5),
                          width: 1.6),
                    ),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        width: 12,
                        height: 16,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          gradient: const LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [Color(0xFFE0A24E), Color(0xFFFFE9B8)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFE0A24E)
                                  .withOpacity( 0.55),
                              blurRadius: 14,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('Lararium',
                  style: TextStyle(
                      fontSize: 31,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -1,
                      color: colors.ink)),
              const SizedBox(height: 10),
              Text(l10n.appTagline,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: colors.ink2)),
              const Spacer(),
              FilledButton(
                onPressed: () {
                  prefs.setBool('onboarded', true);
                  if (context.mounted) context.go('/tree');
                },
                style: FilledButton.styleFrom(
                  backgroundColor: colors.brand,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(l10n.onbCta,
                    style: const TextStyle(
                        fontSize: 15.5, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () {
                  prefs.setBool('onboarded', true);
                  if (context.mounted) context.push('/import');
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.ink,
                  side: BorderSide(color: colors.line2),
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(l10n.onbImportGedcom),
              ),
              const SizedBox(height: 14),
              Text(
                '${l10n.onbNoAccount}\n${l10n.onbDataStays}',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 12, height: 1.6, color: colors.ink4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
