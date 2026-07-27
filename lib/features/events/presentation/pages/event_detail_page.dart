import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/core/l10n/app_localizations.dart';
import 'package:eventix/core/widgets/async_error_view.dart';
import 'package:eventix/features/events/domain/entities/event.dart';
import 'package:eventix/features/events/presentation/providers/event_availability_provider.dart';
import 'package:eventix/features/events/presentation/providers/event_by_id_provider.dart';
import 'package:eventix/features/events/presentation/widgets/event_detail_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EventDetailPage extends ConsumerWidget {
  static const String routePath = '/event/:id';

  const EventDetailPage({required this.eventId, super.key});

  final String eventId;

  static String location(String id) => '/event/$id';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Event> eventAsync = ref.watch(eventByIdProvider(eventId));

    return eventAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: UiLoader()),
      ),
      error: (Object error, _) => Scaffold(
        appBar: AppBar(),
        body: AsyncErrorView(
          message: failureMessage(
            error,
            AppLocalizations.of(context).error_unexpected,
          ),
          onRetry: () => ref.invalidate(eventByIdProvider(eventId)),
        ),
      ),
      data: (Event event) => EventDetailContent(
        event: event,
        available: ref.watch(eventAvailabilityProvider(eventId)),
      ),
    );
  }
}
