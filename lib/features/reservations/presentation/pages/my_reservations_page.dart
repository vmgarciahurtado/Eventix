import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/core/helpers/date_format.dart';
import 'package:eventix/core/widgets/async_error_view.dart';
import 'package:eventix/features/reservations/domain/entities/reservation.dart';
import 'package:eventix/features/reservations/domain/entities/reservation_status.dart';
import 'package:eventix/features/reservations/presentation/providers/reservations_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyReservationsPage extends ConsumerWidget {
  static const String routePath = '/reservations';

  const MyReservationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Reservation>> reservationsAsync = ref.watch(
      myReservationsProvider,
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis reservas'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
            onPressed: () => ref.invalidate(myReservationsProvider),
          ),
        ],
      ),
      body: reservationsAsync.when(
        loading: () => const Center(child: UiLoader()),
        error: (Object e, _) => AsyncErrorView(
          message: failureMessage(e),
          onRetry: () => ref.invalidate(myReservationsProvider),
        ),
        data: (List<Reservation> reservations) {
          if (reservations.isEmpty) {
            return const UiEmptyState(
              icon: Icons.confirmation_num_outlined,
              title: 'Aún no tienes reservas',
              message: 'Cuando reserves un evento aparecerá aquí.',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(UiSpacing.md),
            itemCount: reservations.length,
            itemBuilder: (BuildContext context, int i) =>
                _ReservationCard(reservation: reservations[i]),
          );
        },
      ),
    );
  }
}

class _ReservationCard extends StatelessWidget {
  const _ReservationCard({required this.reservation});

  final Reservation reservation;

  @override
  Widget build(BuildContext context) {
    final bool confirmed =
        reservation.status == ReservationStatus.confirmed;
    final Color statusColor = confirmed
        ? context.statusColors.success
        : context.statusColors.warning;
    return Card(
      margin: const EdgeInsets.only(bottom: UiSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(UiSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    reservation.eventTitle,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: UiSpacing.sm,
                    vertical: UiSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: UiRadius.borderFull,
                  ),
                  child: Text(
                    reservation.status.label,
                    style: context.textTheme.labelSmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: UiSpacing.sm),
            _Row(
              icon: Icons.people_outline,
              text: '${reservation.quantity} cupo(s)',
            ),
            if (reservation.eventStartsAt != null) ...<Widget>[
              const SizedBox(height: UiSpacing.xs),
              _Row(
                icon: Icons.calendar_today_outlined,
                text: formatEventDateTime(reservation.eventStartsAt!),
              ),
            ],
            const SizedBox(height: UiSpacing.xs),
            _Row(
              icon: Icons.event_available_outlined,
              text: 'Reservado el ${formatEventDay(reservation.createdAt)}',
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon, size: 16, color: context.colorScheme.onSurfaceVariant),
        const SizedBox(width: UiSpacing.xs),
        Expanded(
          child: Text(
            text,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
