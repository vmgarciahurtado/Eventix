import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/core/widgets/async_error_view.dart';
import 'package:eventix/features/auth/presentation/providers/auth_providers.dart';
import 'package:eventix/features/events/domain/entities/event.dart';
import 'package:eventix/features/events/presentation/pages/event_detail_page.dart';
import 'package:eventix/features/events/presentation/providers/events_providers.dart';
import 'package:eventix/features/events/presentation/widgets/event_card.dart';
import 'package:eventix/features/events/presentation/widgets/event_filter_bar.dart';
import 'package:eventix/features/reservations/presentation/pages/my_reservations_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Home de la app: listado principal de eventos con filtros.
class HomePage extends ConsumerWidget {
  static const String routePath = '/home';

  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Event>> eventsAsync = ref.watch(eventsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Eventix'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.confirmation_num_outlined),
            tooltip: 'Mis reservas',
            onPressed: () => context.push(MyReservationsPage.routePath),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
            onPressed: () => ref.invalidate(eventsProvider),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () => ref.read(signOutProvider).call(),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          const EventFilterBar(),
          const Divider(height: 1),
          Expanded(
            child: eventsAsync.when(
              loading: () => const Center(child: UiLoader()),
              error: (Object e, _) => AsyncErrorView(
                message: failureMessage(e),
                onRetry: () => ref.invalidate(eventsProvider),
              ),
              data: (List<Event> events) {
                if (events.isEmpty) {
                  return const UiEmptyState(
                    icon: Icons.event_busy_outlined,
                    title: 'Sin eventos',
                    message: 'No encontramos eventos con estos filtros.',
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(UiSpacing.md),
                  itemCount: events.length,
                  itemBuilder: (BuildContext context, int i) => EventCard(
                    event: events[i],
                    onTap: () =>
                        context.push(EventDetailPage.location(events[i].id)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
