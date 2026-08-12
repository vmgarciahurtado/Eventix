import 'dart:async';

import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/core/extensions/localized_text_extension.dart';
import 'package:eventix/core/extensions/snackbar_extension.dart';
import 'package:eventix/core/l10n/app_localizations.dart';
import 'package:eventix/core/widgets/app_empty_state.dart';
import 'package:eventix/core/widgets/async_error_view.dart';
import 'package:eventix/core/widgets/async_view.dart';
import 'package:eventix/features/app_config/domain/entities/app_config.dart';
import 'package:eventix/features/app_config/domain/enums/home_block.dart';
import 'package:eventix/features/app_config/presentation/providers/app_config_provider.dart';
import 'package:eventix/features/auth/presentation/pages/login_page.dart';
import 'package:eventix/features/auth/presentation/providers/logout_provider.dart';
import 'package:eventix/features/events/domain/entities/event.dart';
import 'package:eventix/features/events/presentation/pages/event_detail_page.dart';
import 'package:eventix/features/events/presentation/providers/events_provider.dart';
import 'package:eventix/features/events/presentation/widgets/event_card.dart';
import 'package:eventix/features/events/presentation/widgets/event_filter_bar.dart';
import 'package:eventix/features/events/presentation/widgets/home_banner.dart';
import 'package:eventix/features/reservations/presentation/pages/my_reservations_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class EventsPage extends ConsumerWidget {
  static const String routePath = '/events';

  const EventsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<List<Event>> eventsAsync = ref.watch(eventsProvider);
    final AppConfig config = ref.watch(appConfigProvider);
    final bool loggingOut = ref.watch(logoutProvider).isLoading;

    ref.listen(logoutProvider, (
      AsyncValue<void>? previous,
      AsyncValue<void> next,
    ) {
      switch (next) {
        case AsyncError<void>(:final Object error):
          context.showSnack(failureMessage(error, l10n.error_unexpected));
        case AsyncData<void>():
          context.go(LoginPage.routePath);
        default:
          break;
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          // Atajo de desarrollo: recarga el JSON sin reiniciar la app.
          onLongPress: kDebugMode
              ? () => unawaited(_reloadConfig(context, ref, l10n))
              : null,
          child: Text(l10n.app_name),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.confirmation_num_outlined),
            tooltip: l10n.reservations_title,
            onPressed: () => context.push(MyReservationsPage.routePath),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: l10n.action_refresh,
            onPressed: () => ref.invalidate(eventsProvider),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: l10n.home_logout,
            onPressed: loggingOut
                ? null
                : ref.read(logoutProvider.notifier).logout,
          ),
        ],
      ),
      // Qué bloques se pintan y en qué orden lo decide el JSON.
      body: Column(
        children: <Widget>[
          for (final HomeBlock block in config.home.blocks)
            _block(block, context, ref, config, eventsAsync),
        ],
      ),
    );
  }

  Widget _block(
    HomeBlock block,
    BuildContext context,
    WidgetRef ref,
    AppConfig config,
    AsyncValue<List<Event>> eventsAsync,
  ) => switch (block) {
    HomeBlock.banner => const HomeBanner(),
    HomeBlock.filters => const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[EventFilterBar(), Divider(height: 1)],
    ),
    HomeBlock.events => Expanded(
      child: AsyncView<List<Event>>(
        value: eventsAsync,
        onRetry: () => ref.invalidate(eventsProvider),
        data: (List<Event> events) {
          if (events.isEmpty) {
            return AppEmptyState(
              title: config.home.emptyState.title.of(context),
              message: config.home.emptyState.message.of(context),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(UiSpacing.medium),
            itemCount: events.length,
            itemBuilder: (BuildContext context, int i) => EventCard(
              event: events[i],
              onTap: () => context.push(EventDetailPage.location(events[i].id)),
            ),
          );
        },
      ),
    ),
  };

  Future<void> _reloadConfig(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final bool reloaded = await ref.read(appConfigProvider.notifier).reload();
    if (!context.mounted) return;
    context.showSnack(
      reloaded ? l10n.config_reloaded : l10n.config_reload_error,
    );
  }
}
