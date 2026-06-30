import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/core/extensions/snackbar_extension.dart';
import 'package:eventix/core/helpers/date_format.dart';
import 'package:eventix/core/helpers/money_format.dart';
import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/core/widgets/async_error_view.dart';
import 'package:eventix/features/events/domain/entities/event.dart';
import 'package:eventix/features/events/presentation/providers/events_providers.dart';
import 'package:eventix/features/payments/domain/entities/checkout_session.dart';
import 'package:eventix/features/payments/presentation/pages/checkout_web_view_page.dart';
import 'package:eventix/features/payments/presentation/providers/payments_providers.dart';
import 'package:eventix/features/reservations/domain/entities/reservation.dart';
import 'package:eventix/features/reservations/presentation/pages/my_reservations_page.dart';
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
  bool _loading = false;
  bool _wantInvoice = true;

  int _maxQuantity(Event event) {
    final int cap = event.capacity < 1 ? 1 : event.capacity;
    return cap < 10 ? cap : 10;
  }

  Future<void> _startPurchase(Event event) async {
    final double total = event.price * _quantity;

    // Eventos gratuitos: no pasan por Stripe, se reservan directo.
    if (total <= 0) {
      final bool? confirmed = await UiConfirmDialog.show(
        context,
        title: 'Reservar',
        message:
            'Vas a reservar $_quantity cupo(s) para "${event.title}". '
            'Este evento es gratuito. ¿Confirmar?',
      );
      if (confirmed != true) return;
      await _confirmReservation();
      return;
    }

    final bool? confirmed = await UiConfirmDialog.show(
      context,
      title: 'Pagar con Stripe',
      message:
          'Vas a pagar ${formatPrice(total)} por $_quantity cupo(s) para '
          '"${event.title}".',
    );
    if (confirmed != true) return;

    setState(() => _loading = true);
    final Result<CheckoutSession> result = await ref
        .read(createCheckoutSessionProvider)
        .call(
          eventId: widget.eventId,
          quantity: _quantity,
          wantInvoice: _wantInvoice,
        );
    if (!mounted) return;
    setState(() => _loading = false);

    switch (result) {
      case Success<CheckoutSession>(data: final CheckoutSession session):
        await _payInWebView(session);
      case FailureResult<CheckoutSession>(failure: final Failure failure):
        context.showSnack(failure.userMessage);
    }
  }

  Future<void> _payInWebView(CheckoutSession session) async {
    final String? status = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (_) => CheckoutWebViewPage(url: session.url),
      ),
    );
    if (!mounted) return;

    if (status == 'success') {
      await _verifyAndFinish(session.sessionId);
    } else {
      context.showSnack('Pago cancelado.');
    }
  }

  Future<void> _verifyAndFinish(String sessionId) async {
    setState(() => _loading = true);
    final Result<bool> result = await ref
        .read(verifyCheckoutSessionProvider)
        .call(sessionId: sessionId);
    if (!mounted) return;

    switch (result) {
      case Success<bool>(data: final bool paid):
        if (paid) {
          await _confirmReservation();
        } else {
          setState(() => _loading = false);
          context.showSnack('No pudimos confirmar el pago. Intenta de nuevo.');
        }
      case FailureResult<bool>(failure: final Failure failure):
        setState(() => _loading = false);
        context.showSnack(failure.userMessage);
    }
  }

  Future<void> _confirmReservation() async {
    setState(() => _loading = true);
    final Result<Reservation> result = await ref
        .read(createReservationProvider)
        .call(eventId: widget.eventId, quantity: _quantity);
    if (!mounted) return;

    switch (result) {
      case Success<Reservation>():
        ref.invalidate(myReservationsProvider);
        context.showSnack('¡Reserva confirmada!');
        context.go(MyReservationsPage.routePath);
      case FailureResult<Reservation>(failure: final Failure failure):
        setState(() => _loading = false);
        context.showSnack(failure.userMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
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
        data: (Event event) => _body(event),
      ),
    );
  }

  Widget _body(Event event) {
    final double total = event.price * _quantity;
    final int max = _maxQuantity(event);
    final bool isFree = total <= 0;
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
            const SizedBox(height: UiSpacing.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Cantidad de cupos', style: context.textTheme.titleMedium),
                _QuantityStepper(
                  value: _quantity,
                  max: max,
                  onChanged: _loading
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
                  isFree ? 'Gratis' : formatPrice(event.price),
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
                  isFree ? 'Gratis' : formatPrice(total),
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
                onChanged: _loading
                    ? (_) {}
                    : (bool v) => setState(() => _wantInvoice = v),
                label: 'Enviar la factura a mi correo',
              ),
            ],
            const SizedBox(height: UiSpacing.xl),
            UiButton(
              label: isFree
                  ? 'Reservar gratis'
                  : 'Pagar ${formatPrice(total)}',
              expanded: true,
              loading: _loading,
              onPressed: () => _startPurchase(event),
            ),
          ],
        ),
      ),
    );
  }
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
