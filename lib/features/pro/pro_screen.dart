import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme.dart';
import '../../data/billing_service.dart';
import '../../data/providers.dart';

/// 09 Pro 会员页：定价 + 6 项权益 + 「免费版永远保留缅怀闭环」声明。
/// 支付走 Google Play Billing；商店配置完成前优雅降级（规划文档第八章红线）。
class ProScreen extends ConsumerStatefulWidget {
  const ProScreen({super.key});

  @override
  ConsumerState<ProScreen> createState() => _ProScreenState();
}

class _ProScreenState extends ConsumerState<ProScreen> {
  ProductDetails? _product;
  bool _storeAvailable = false;
  StreamSubscription? _purchaseSub;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final prefs = ref.read(prefsProvider);
    final billing = BillingService(prefs);
    _purchaseSub = billing.listen((active) {
      if (mounted) setState(() {});
    });
    final products = await billing.queryProduct();
    if (mounted && products != null && products.isNotEmpty) {
      setState(() {
        _storeAvailable = true;
        _product = products.first;
      });
    }
  }

  @override
  void dispose() {
    _purchaseSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(context) {
    final colors = Theme.of(context).extension<LarariumColors>()!;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        title: Text(l10n.proTitle,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 30),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2E6B4F), Color(0xFF1B4433)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_product?.price ?? '\$19.99',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 5),
                Text(AppLocalizations.of(context).proPriceSub,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 13.5)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _card(colors, [
            _feat(colors, Icons.sync, l10n.proFeatSync, l10n.proFeatSyncSub),
            _feat(colors, Icons.local_florist, l10n.proFeatTribute, l10n.proFeatTributeSub),
            _feat(colors, Icons.light_mode, l10n.proFeatCandle, l10n.proFeatCandleSub),
            _feat(colors, Icons.mic_none, l10n.proFeatVoice, l10n.proFeatVoiceSub),
            _feat(colors, Icons.picture_as_pdf_outlined, l10n.proFeatExport, l10n.proFeatExportSub),
            _feat(colors, Icons.block_outlined, l10n.proFeatAds, l10n.proFeatAdsSub),
          ]),
          const SizedBox(height: 20),
          SizedBox(
            height: 50,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: colors.brand,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () async {
                final prefs = ref.read(prefsProvider);
                final billing = BillingService(prefs);
                final product = _product;
                if (!_storeAvailable || product == null) {
                  // 商店未配置（合规红线：绝不引导外部支付）
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(l10n.proCta),
                      content: Text(l10n.proBillingUnavailable),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: Text(l10n.done)),
                      ],
                    ),
                  );
                  return;
                }
                await billing.buy(product);
              },
              child: Text(l10n.proCta,
                  style: const TextStyle(
                      fontSize: 15.5, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 14),
          Text(l10n.proNote,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 11.5, height: 1.6, color: colors.ink4)),
        ],
      ),
    );
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

  Widget _feat(LarariumColors colors, IconData icon, String title, String sub) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: colors.brandSoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 17, color: colors.brand),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: colors.ink)),
                const SizedBox(height: 2),
                Text(sub,
                    style: TextStyle(fontSize: 12.5, color: colors.ink3)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
