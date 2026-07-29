import 'dart:async';

import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/core/extensions/snackbar_extension.dart';
import 'package:eventix/core/l10n/app_localizations.dart';
import 'package:eventix/core/widgets/async_view.dart';
import 'package:eventix/features/events/domain/entities/event.dart';
import 'package:eventix/features/events/presentation/providers/event_availability_provider.dart';
import 'package:eventix/features/events/presentation/providers/event_by_id_provider.dart';
import 'package:eventix/features/payments/domain/entities/checkout_session.dart';
import 'package:eventix/features/payments/domain/enums/checkout_result.dart';
import 'package:eventix/features/payments/presentation/pages/checkout_web_view_page.dart';
import 'package:eventix/features/reservations/presentation/pages/reservation_confirmed_page.dart';
import 'package:eventix/features/reservations/presentation/providers/my_reservations_provider.dart';
import 'package:eventix/features/reservations/presentation/providers/purchase_provider.dart';
import 'package:eventix/features/reservations/presentation/providers/purchase_state.dart';
import 'package:eventix/features/reservations/presentation/widgets/reserve_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ReservePage extends ConsumerWidget {
  static const String routePath = '/reserve/:id';

  const ReservePage({required this.eventId, super.key});

  final String eventId;

  static String location(String id) => '/reserve/$id';

  /// Abre el checkout y devuelve el resultado al flujo de compra. Cerrar el
  /// WebView sin resultado cuenta como cancelar.
  Future<void> _openCheckout(
    BuildContext context,
    WidgetRef ref,
    CheckoutSession session,
  ) async {
    final CheckoutResult? result = await Navigator.of(context)
        .push<CheckoutResult>(
          MaterialPageRoute<CheckoutResult>(
            builder: (_) => CheckoutWebViewPage(
              url: session.url,
              returnUrlMarker: session.returnUrlMarker,
            ),
          ),
        );
    if (!context.mounted) return;
    await ref
        .read(purchaseProvider.notifier)
        .finishPayment(result ?? CheckoutResult.cancel);
  }

  void _onPurchaseChanged(
    BuildContext context,
    WidgetRef ref,
    PurchaseState next,
  ) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    switch (next) {
      case PurchaseAwaitingPayment(session: final CheckoutSession session):
        unawaited(_openCheckout(context, ref, session));
      case PurchaseSuccess():
        ref.invalidate(myReservationsProvider);
        ref.invalidate(eventAvailabilityProvider(eventId));
        context.go(ReservationConfirmedPage.routePath);
      case PurchaseCancelled():
        ref.invalidate(eventAvailabilityProvider(eventId));
        context.showSnack(l10n.reserve_cancelled);
      case PurchaseNotPaid():
        ref.invalidate(eventAvailabilityProvider(eventId));
        context.showSnack(l10n.reserve_not_paid);
      case PurchaseUnconfirmed():
        context.showSnack(l10n.reserve_unconfirmed);
      case PurchaseFailed(failure: final Failure failure):
        ref.invalidate(eventAvailabilityProvider(eventId));
        context.showSnack(failure.userMessage);
      case PurchaseIdle():
      case PurchaseWorking():
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Event> eventAsync = ref.watch(eventByIdProvider(eventId));

    ref.listen(purchaseProvider, (
      PurchaseState? previous,
      PurchaseState next,
    ) {
      _onPurchaseChanged(context, ref, next);
    });

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).action_reserve)),
      body: AsyncView<Event>(
        value: eventAsync,
        onRetry: () => ref.invalidate(eventByIdProvider(eventId)),
        data: (Event event) => ReserveForm(event: event),
      ),
    );
  }
}
