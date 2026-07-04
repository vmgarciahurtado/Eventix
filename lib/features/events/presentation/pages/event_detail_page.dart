import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/core/helpers/date_format.dart';
import 'package:eventix/core/helpers/money_format.dart';
import 'package:eventix/core/widgets/async_error_view.dart';
import 'package:eventix/features/events/domain/entities/event.dart';
import 'package:eventix/features/events/presentation/providers/events_providers.dart';
import 'package:eventix/features/events/presentation/widgets/event_image.dart';
import 'package:eventix/features/reservations/presentation/pages/reserve_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class EventDetailPage extends ConsumerWidget {
  static const String routePath = '/event/:id';

  const EventDetailPage({required this.eventId, super.key});

  final String eventId;

  static String location(String id) => '/event/$id';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Event> eventAsync = ref.watch(eventByIdProvider(eventId));
    return Scaffold(
      body: eventAsync.when(
        loading: () => const Center(child: UiLoader()),
        error: (Object e, _) => Scaffold(
          appBar: AppBar(),
          body: AsyncErrorView(
            message: failureMessage(e),
            onRetry: () => ref.invalidate(eventByIdProvider(eventId)),
          ),
        ),
        data: (Event event) => _DetailContent(
          event: event,
          available: ref.watch(eventAvailabilityProvider(eventId)),
        ),
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({required this.event, required this.available});

  final Event event;
  final AsyncValue<int> available;

  String get _spotsLabel => available.when(
    data: (int a) =>
        a <= 0 ? 'Agotado' : '$a de ${event.capacity} cupos disponibles',
    loading: () => '${event.capacity} cupos',
    error: (_, _) => '${event.capacity} cupos',
  );

  @override
  Widget build(BuildContext context) {
    final bool soldOut = (available.value ?? 1) <= 0;
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: EventImage(
                imageKey: event.imageKey,
                categoryName: event.categoryName,
                height: 200,
                iconSize: 96,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(UiSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    event.title,
                    style: context.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: UiSpacing.sm),
                  Wrap(
                    spacing: UiSpacing.sm,
                    runSpacing: UiSpacing.xs,
                    children: <Widget>[
                      Chip(label: Text(event.categoryName)),
                      Chip(
                        avatar: const Icon(
                          Icons.location_on_outlined,
                          size: 16,
                        ),
                        label: Text(event.cityName),
                      ),
                    ],
                  ),
                  const SizedBox(height: UiSpacing.md),
                  _InfoRow(
                    icon: Icons.calendar_today_outlined,
                    text: formatEventDateTime(event.startsAt),
                  ),
                  const SizedBox(height: UiSpacing.sm),
                  _InfoRow(
                    icon: Icons.confirmation_num_outlined,
                    text: formatPrice(event.price),
                  ),
                  const SizedBox(height: UiSpacing.sm),
                  _InfoRow(
                    icon: Icons.people_outline,
                    text: _spotsLabel,
                  ),
                  const SizedBox(height: UiSpacing.lg),
                  Text(
                    'Descripción',
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: UiSpacing.xs),
                  Text(event.description, style: context.textTheme.bodyLarge),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(UiSpacing.lg),
          child: UiButton(
            label: soldOut ? 'Agotado' : 'Reservar',
            expanded: true,
            onPressed: soldOut
                ? null
                : () => context.push(ReservePage.location(event.id)),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon, size: 20, color: context.colorScheme.primary),
        const SizedBox(width: UiSpacing.sm),
        Expanded(child: Text(text, style: context.textTheme.bodyLarge)),
      ],
    );
  }
}
