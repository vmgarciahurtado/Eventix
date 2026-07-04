import 'dart:async';

import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/core/extensions/snackbar_extension.dart';
import 'package:eventix/core/helpers/date_format.dart';
import 'package:eventix/core/helpers/money_format.dart';
import 'package:eventix/core/widgets/async_error_view.dart';
import 'package:eventix/features/events/domain/entities/event.dart';
import 'package:eventix/features/events/presentation/providers/events_providers.dart';
import 'package:eventix/features/payments/domain/entities/checkout_result.dart';
import 'package:eventix/features/payments/domain/entities/checkout_session.dart';
import 'package:eventix/features/payments/presentation/pages/checkout_web_view_page.dart';
import 'package:eventix/features/reservations/domain/usecases/purchase_tickets.dart';
import 'package:eventix/features/reservations/presentation/pages/my_reservations_page.dart';
import 'package:eventix/features/reservations/presentation/providers/purchase_provider.dart';
import 'package:eventix/features/reservations/presentation/providers/reservations_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ReservePage extends ConsumerStatefulWidget {
  static const String routePath = '/reserve/:id';

  const ReservePage({required this.eventId, super.key});

  final String eventId;

  static String location(String id) => '/reserve/$id';

  @override
  ConsumerState<ReservePage> createState() => _ReservePageState();
}

class _ReservePageState extends ConsumerState<ReservePage> {
  int _quantity = 1;
  bool _wantInvoice = true;

  Future<void> _startPurchase(Event event) async {
    final double total = event.price * _quantity;
    final bool isFree = total <= 0;

    final bool? confirmed = await UiConfirmDialog.show(
      context,
      title: isFree ? 'Reservar' : 'Pagar con Stripe',
      message: isFree
          ? 'Vas a reservar $_quantity cupo(s) para "${event.title}". '
                'Este evento es gratuito. ¿Confirmar?'
          : 'Vas a pagar ${formatPrice(total)} por $_quantity cupo(s) para '
                '"${event.title}".',
    );
    if (confirmed != true) return;

    await ref
        .read(purchaseProvider.notifier)
        .start(
          eventId: widget.eventId,
          unitPrice: event.price,
          quantity: _quantity,
          wantInvoice: _wantInvoice,
        );
  }

  Future<void> _openCheckout(CheckoutSession session) async {
    final CheckoutResult? result = await Navigator.of(context)
        .push<CheckoutResult>(
          MaterialPageRoute<CheckoutResult>(
            builder: (_) => CheckoutWebViewPage(url: session.url),
          ),
        );
    if (!mounted) return;
    await ref
        .read(purchaseProvider.notifier)
        .finishPayment(result ?? CheckoutResult.cancel);
  }

  void _onPurchaseChanged(PurchaseState? previous, PurchaseState next) {
    switch (next) {
      case PurchaseAwaitingPayment(session: final CheckoutSession session):
        unawaited(_openCheckout(session));
      case PurchaseSuccess():
        ref.invalidate(myReservationsProvider);
        ref.invalidate(eventAvailabilityProvider(widget.eventId));
        context.showSnack('¡Reserva confirmada!');
        context.go(MyReservationsPage.routePath);
      case PurchaseCancelled():
        ref.invalidate(eventAvailabilityProvider(widget.eventId));
        context.showSnack('Pago cancelado. No se realizó la reserva.');
      case PurchaseUnconfirmed():
        context.showSnack(
          'Recibimos tu pago pero la reserva no pudo confirmarse. '
          'Escríbenos para resolverlo.',
        );
      case PurchaseFailed(failure: final Failure failure):
        ref.invalidate(eventAvailabilityProvider(widget.eventId));
        context.showSnack(failure.userMessage);
      case PurchaseIdle():
      case PurchaseWorking():
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(purchaseProvider, _onPurchaseChanged);
    final AsyncValue<Event> eventAsync = ref.watch(
      eventByIdProvider(widget.eventId),
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Reservar')),
      body: eventAsync.when(
        loading: () => const Center(child: UiLoader()),
        error: (Object e, _) => AsyncErrorView(
          message: failureMessage(e),
          onRetry: () => ref.invalidate(eventByIdProvider(widget.eventId)),
        ),
        data: _body,
      ),
    );
  }

  Widget _body(Event event) {
    final PurchaseState purchase = ref.watch(purchaseProvider);
    final bool loading =
        purchase is PurchaseWorking || purchase is PurchaseAwaitingPayment;
    final AsyncValue<int> availableAsync = ref.watch(
      eventAvailabilityProvider(widget.eventId),
    );
    final int? available = availableAsync.value;
    final int max = _maxQuantity(available);
    if (_quantity > max) _quantity = max;
    final double total = event.price * _quantity;
    final bool isFree = total <= 0;
    final bool soldOut = available != null && available <= 0;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(UiSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              event.title,
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: UiSpacing.xs),
            Text(
              formatEventDateTime(event.startsAt),
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: UiSpacing.xs),
            Text(
              _availabilityLabel(availableAsync, event.capacity),
              style: context.textTheme.bodyMedium?.copyWith(
                color: soldOut
                    ? context.colorScheme.error
                    : context.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: UiSpacing.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Cantidad de cupos', style: context.textTheme.titleMedium),
                _QuantityStepper(
                  value: _quantity,
                  max: max,
                  onChanged: loading
                      ? null
                      : (int v) => setState(() => _quantity = v),
                ),
              ],
            ),
            const Divider(height: UiSpacing.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Precio unitario', style: context.textTheme.bodyLarge),
                Text(
                  formatPrice(event.price),
                  style: context.textTheme.bodyLarge,
                ),
              ],
            ),
            const SizedBox(height: UiSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Total',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  formatPrice(total),
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colorScheme.primary,
                  ),
                ),
              ],
            ),
            if (!isFree) ...<Widget>[
              const SizedBox(height: UiSpacing.lg),
              UiCheckOption(
                value: _wantInvoice,
                onChanged: loading
                    ? (_) {}
                    : (bool v) => setState(() => _wantInvoice = v),
                label: 'Enviar la factura a mi correo',
              ),
            ],
            const SizedBox(height: UiSpacing.xl),
            UiButton(
              label: soldOut
                  ? 'Agotado'
                  : isFree
                  ? 'Reservar gratis'
                  : 'Pagar ${formatPrice(total)}',
              expanded: true,
              loading: loading,
              onPressed: soldOut ? null : () => _startPurchase(event),
            ),
          ],
        ),
      ),
    );
  }

  /// Tope por compra: la regla vive en domain ([PurchaseTickets]); la UI solo
  /// la acota a los cupos realmente disponibles.
  int _maxQuantity(int? available) {
    final int cap = available ?? PurchaseTickets.maxPerPurchase;
    final int max = cap < PurchaseTickets.maxPerPurchase
        ? cap
        : PurchaseTickets.maxPerPurchase;
    return max < 1 ? 1 : max;
  }

  String _availabilityLabel(AsyncValue<int> available, int capacity) =>
      available.when(
        data: (int a) => a <= 0
            ? 'Evento agotado'
            : '$a de $capacity cupos disponibles',
        loading: () => 'Consultando disponibilidad…',
        error: (_, _) => '$capacity cupos en total',
      );
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.value,
    required this.max,
    required this.onChanged,
  });

  final int value;
  final int max;
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        IconButton.filledTonal(
          icon: const Icon(Icons.remove),
          onPressed: (onChanged == null || value <= 1)
              ? null
              : () => onChanged!(value - 1),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: UiSpacing.md),
          child: Text('$value', style: context.textTheme.titleLarge),
        ),
        IconButton.filledTonal(
          icon: const Icon(Icons.add),
          onPressed: (onChanged == null || value >= max)
              ? null
              : () => onChanged!(value + 1),
        ),
      ],
    );
  }
}
