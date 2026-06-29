import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/core/extensions/snackbar_extension.dart';
import 'package:eventix/core/helpers/date_format.dart';
import 'package:eventix/core/helpers/money_format.dart';
import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/core/widgets/async_error_view.dart';
import 'package:eventix/features/events/domain/entities/event.dart';
import 'package:eventix/features/events/presentation/providers/events_providers.dart';
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

  int _maxQuantity(Event event) {
    final int cap = event.capacity < 1 ? 1 : event.capacity;
    return cap < 10 ? cap : 10;
  }

  Future<void> _simulatePurchase(Event event) async {
    final bool? confirmed = await UiConfirmDialog.show(
      context,
      title: 'Simular compra',
      message:
          'Vas a reservar $_quantity cupo(s) para "${event.title}" por '
          '${formatPrice(event.price * _quantity)}. ¿Confirmar?',
    );
    if (confirmed != true) return;

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
    return SafeArea(
      child: Padding(
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
            const Spacer(),
            UiButton(
              label: 'Simular compra',
              expanded: true,
              loading: _loading,
              onPressed: () => _simulatePurchase(event),
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
