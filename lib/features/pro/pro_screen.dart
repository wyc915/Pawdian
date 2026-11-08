import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/billing/billing.dart';
import '../../core/settings/app_settings.dart';
import '../../l10n/app_localizations.dart';

final proOffersProvider = FutureProvider.autoDispose<List<ProOffer>>(
  (ref) => ref.watch(billingGatewayProvider).loadOffers(),
);

/// Paywall: lists the store's Pro products and handles purchases.
class ProScreen extends ConsumerStatefulWidget {
  const ProScreen({super.key});

  @override
  ConsumerState<ProScreen> createState() => _ProScreenState();
}

class _ProScreenState extends ConsumerState<ProScreen> {
  StreamSubscription<BillingEvent>? _sub;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _sub = ref.read(billingGatewayProvider).events.listen(_onEvent);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _onEvent(BillingEvent e) {
    if (!mounted) return;
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    String? message;
    switch (e) {
      case PurchaseSucceeded():
        // BillingController already stored the entitlement.
        message = l.proActive;
      case PurchasePending():
        message = l.proPending;
      case PurchaseFailed(:final message):
        messenger.showSnackBar(SnackBar(content: Text(l.proFailed(message))));
      case PurchaseCanceled():
        break;
    }
    if (message != null) {
      messenger.showSnackBar(SnackBar(content: Text(message)));
    }
    setState(() => _busy = false);
  }

  Future<void> _buy(ProProduct p) async {
    setState(() => _busy = true);
    try {
      await ref.read(billingGatewayProvider).buy(p);
    } catch (e) {
      _onEvent(PurchaseFailed('$e'));
    }
  }

  Future<void> _restore() async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    final answered = await ref.read(billingControllerProvider).refresh();
    if (!mounted) return;
    setState(() => _busy = false);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          !answered
              ? l.proUnavailable
              : ref.read(isProProvider)
              ? l.proRestored
              : l.proNothingToRestore,
        ),
      ),
    );
  }

  String _productLabel(AppLocalizations l, ProProduct p) => switch (p) {
    ProProduct.yearly => l.proYearly,
    ProProduct.monthly => l.proMonthly,
    ProProduct.lifetime => l.proLifetime,
  };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isPro = ref.watch(isProProvider);
    final offers = ref.watch(proOffersProvider);
    final features = [
      (Icons.pets, l.proFeaturePets),
      (Icons.show_chart, l.proFeatureHistory),
      (Icons.picture_as_pdf_outlined, l.proFeatureReport),
      (Icons.photo_library_outlined, l.proFeatureAttachments),
      (Icons.table_chart_outlined, l.proFeatureCsv),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(l.proTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l.proHeadline, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 16),
          for (final (icon, text) in features)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(icon, color: theme.colorScheme.primary),
              title: Text(text),
            ),
          const SizedBox(height: 16),
          if (isPro)
            Card(
              child: ListTile(
                leading: const Icon(Icons.verified),
                title: Text(l.proActive),
              ),
            )
          else
            offers.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => Text(l.proUnavailable),
              data: (list) => list.isEmpty
                  ? Text(l.proUnavailable)
                  : Column(
                      children: [
                        for (final o in list)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: SizedBox(
                              width: double.infinity,
                              child: o.product == ProProduct.yearly
                                  ? FilledButton(
                                      onPressed: _busy
                                          ? null
                                          : () => _buy(o.product),
                                      child: Text(
                                        '${_productLabel(l, o.product)}  ${o.price}',
                                      ),
                                    )
                                  : OutlinedButton(
                                      onPressed: _busy
                                          ? null
                                          : () => _buy(o.product),
                                      child: Text(
                                        '${_productLabel(l, o.product)}  ${o.price}',
                                      ),
                                    ),
                            ),
                          ),
                      ],
                    ),
            ),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              key: const Key('pro.restore'),
              onPressed: _busy ? null : _restore,
              child: Text(l.proRestore),
            ),
          ),
          const SizedBox(height: 8),
          Text(l.proTerms, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}
