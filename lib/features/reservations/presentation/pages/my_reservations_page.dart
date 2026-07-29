import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/core/l10n/app_localizations.dart';
import 'package:eventix/core/widgets/app_empty_state.dart';
import 'package:eventix/core/widgets/async_view.dart';
import 'package:eventix/features/reservations/domain/entities/reservation.dart';
import 'package:eventix/features/reservations/presentation/providers/my_reservations_provider.dart';
import 'package:eventix/features/reservations/presentation/widgets/reservation_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyReservationsPage extends ConsumerWidget {
  static const String routePath = '/reservations';

  const MyReservationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<List<Reservation>> reservationsAsync = ref.watch(
      myReservationsProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.reservations_title),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: l10n.action_refresh,
            onPressed: () => ref.invalidate(myReservationsProvider),
          ),
        ],
      ),
      body: AsyncView<List<Reservation>>(
        value: reservationsAsync,
        onRetry: () => ref.invalidate(myReservationsProvider),
        data: (List<Reservation> reservations) {
          if (reservations.isEmpty) {
            return AppEmptyState(
              title: l10n.reservations_empty_title,
              message: l10n.reservations_empty_message,
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(UiSpacing.medium),
            itemCount: reservations.length,
            itemBuilder: (BuildContext context, int i) =>
                ReservationCard(reservation: reservations[i]),
          );
        },
      ),
    );
  }
}
