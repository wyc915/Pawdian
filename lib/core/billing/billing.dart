import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

import '../settings/app_settings.dart';

/// Product ids, created in Google Play Console (Monetize > Products).
/// Subscriptions: pawdian_pro_yearly, pawdian_pro_monthly.
/// One-time product: pawdian_pro_lifetime.
enum ProProduct {
  yearly('pawdian_pro_yearly'),
  monthly('pawdian_pro_monthly'),
  lifetime('pawdian_pro_lifetime');

  const ProProduct(this.id);

  final String id;

  static ProProduct? fromId(String id) =>
      values.where((p) => p.id == id).firstOrNull;
}

class ProOffer {
  const ProOffer({required this.product, required this.price});

  final ProProduct product;

  /// Localized price string from the store, e.g. "NT$490".
  final String price;
}

sealed class BillingEvent {
  const BillingEvent();
}

class PurchaseSucceeded extends BillingEvent {
  const PurchaseSucceeded(this.product);
  final ProProduct product;
}

class PurchasePending extends BillingEvent {
  const PurchasePending();
}

class PurchaseCanceled extends BillingEvent {
  const PurchaseCanceled();
}

class PurchaseFailed extends BillingEvent {
  const PurchaseFailed(this.message);
  final String message;
}

/// Thin wrapper over the store so tests can use a fake.
abstract class BillingGateway {
  Stream<BillingEvent> get events;
  Future<bool> isAvailable();
  Future<List<ProOffer>> loadOffers();
  Future<void> buy(ProProduct product);

  /// Pro products the user currently owns, or null if the store could not
  /// give a definite answer (offline, not signed in…).
  Future<Set<ProProduct>?> ownedProducts();

  void dispose();
}

class PlayBillingGateway implements BillingGateway {
  PlayBillingGateway() {
    _sub = _iap.purchaseStream.listen(
      _onPurchases,
      onError: (Object e) => _events.add(PurchaseFailed('$e')),
    );
  }

  final _iap = InAppPurchase.instance;
  final _events = StreamController<BillingEvent>.broadcast();
  final _details = <ProProduct, ProductDetails>{};
  late final StreamSubscription<List<PurchaseDetails>> _sub;

  @override
  Stream<BillingEvent> get events => _events.stream;

  @override
  Future<bool> isAvailable() => _iap.isAvailable();

  @override
  Future<List<ProOffer>> loadOffers() async {
    if (!await isAvailable()) return const [];
    final response = await _iap.queryProductDetails({
      for (final p in ProProduct.values) p.id,
    });
    final offers = <ProOffer>[];
    for (final d in response.productDetails) {
      final product = ProProduct.fromId(d.id);
      if (product == null || _details.containsKey(product)) continue;
      // Subscriptions can come back once per offer; keep the first.
      _details[product] = d;
      offers.add(ProOffer(product: product, price: d.price));
    }
    offers.sort((a, b) => a.product.index.compareTo(b.product.index));
    return offers;
  }

  @override
  Future<void> buy(ProProduct product) async {
    final details = _details[product];
    if (details == null) {
      _events.add(const PurchaseFailed('Product not loaded'));
      return;
    }
    // Subscriptions and the lifetime unlock are both non-consumable.
    await _iap.buyNonConsumable(
      purchaseParam: PurchaseParam(productDetails: details),
    );
  }

  @override
  Future<Set<ProProduct>?> ownedProducts() async {
    if (defaultTargetPlatform != TargetPlatform.android) return null;
    try {
      if (!await isAvailable()) return null;
      final addition = _iap
          .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
      final response = await addition.queryPastPurchases();
      if (response.error != null) return null;
      final owned = <ProProduct>{};
      for (final p in response.pastPurchases) {
        if (p.status == PurchaseStatus.purchased ||
            p.status == PurchaseStatus.restored) {
          final product = ProProduct.fromId(p.productID);
          if (product != null) owned.add(product);
          if (p.pendingCompletePurchase) await _iap.completePurchase(p);
        }
      }
      return owned;
    } catch (e) {
      debugPrint('Querying purchases failed: $e');
      return null;
    }
  }

  Future<void> _onPurchases(List<PurchaseDetails> purchases) async {
    for (final p in purchases) {
      switch (p.status) {
        case PurchaseStatus.pending:
          _events.add(const PurchasePending());
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          final product = ProProduct.fromId(p.productID);
          if (product != null) _events.add(PurchaseSucceeded(product));
        case PurchaseStatus.canceled:
          _events.add(const PurchaseCanceled());
        case PurchaseStatus.error:
          _events.add(PurchaseFailed(p.error?.message ?? 'Unknown error'));
      }
      // Acknowledge; Google refunds purchases not acknowledged in 3 days.
      if (p.pendingCompletePurchase) await _iap.completePurchase(p);
    }
  }

  @override
  void dispose() {
    _sub.cancel();
    _events.close();
  }
}

final billingGatewayProvider = Provider<BillingGateway>((ref) {
  final gateway = PlayBillingGateway();
  ref.onDispose(gateway.dispose);
  return gateway;
});

/// Keeps [isProProvider] in sync with the store.
class BillingController {
  BillingController(this._ref) {
    _sub = _ref.read(billingGatewayProvider).events.listen((e) {
      if (e is PurchaseSucceeded) {
        _ref.read(isProProvider.notifier).setOwned(true);
      }
    });
  }

  final Ref _ref;
  late final StreamSubscription<BillingEvent> _sub;

  /// Re-checks ownership (app start, restore button). Returns whether the
  /// store answered.
  Future<bool> refresh() async {
    final owned = await _ref.read(billingGatewayProvider).ownedProducts();
    if (owned == null) return false;
    await _ref.read(isProProvider.notifier).setOwned(owned.isNotEmpty);
    return true;
  }

  void dispose() => _sub.cancel();
}

final billingControllerProvider = Provider<BillingController>((ref) {
  final c = BillingController(ref);
  ref.onDispose(c.dispose);
  return c;
});
