import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Pro 订阅（Google Play Billing / App Store）。
/// 商品 ID 固定 `pro_year`（Play Console 配置后自动可见）；
/// 无商店配置的构建（模拟器调试）优雅降级：查询结果为空 → UI 显示说明。
class BillingService {
  BillingService(this._prefs);

  final SharedPreferences _prefs;
  static const productId = 'pro_year';

  final _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _sub;

  bool get isPro => _prefs.getBool('pro_active') ?? false;

  Future<bool> get storeAvailable => _iap.isAvailable();

  /// 查询商品（返回 null = 商店不可用；空列表 = 商品未配置）
  Future<List<ProductDetails>?> queryProduct() async {
    if (!await storeAvailable) return null;
    final resp = await _iap.queryProductDetails({productId});
    return resp.productDetails;
  }

  Future<void> buy(ProductDetails product) async {
    await _iap.buyNonConsumable(purchaseParam: PurchaseParam(productDetails: product));
  }

  /// 监听购买流（App 启动时挂上；购买完成/恢复即写入 Pro 标记）
  StreamSubscription<List<PurchaseDetails>> listen(
    void Function(bool active) onChanged,
  ) {
    return _iap.purchaseStream.listen((purchases) {
      for (final p in purchases) {
        final done = p.status == PurchaseStatus.purchased ||
            p.status == PurchaseStatus.restored;
        if (done) {
          _prefs.setBool('pro_active', true);
          onChanged(true);
        }
        if (p.pendingCompletePurchase) {
          _iap.completePurchase(p);
        }
      }
    });
  }
}
