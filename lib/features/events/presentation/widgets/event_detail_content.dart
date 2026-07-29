import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/core/helpers/date_format.dart';
import 'package:eventix/core/helpers/money_format.dart';
import 'package:eventix/core/l10n/app_localizations.dart';
import 'package:eventix/features/events/domain/entities/event.dart';
import 'package:eventix/features/events/presentation/widgets/event_image.dart';
import 'package:eventix/features/events/presentation/widgets/event_info_row.dart';
import 'package:eventix/features/reservations/presentation/pages/reserve_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class EventDetailContent extends StatelessWidget {
  const EventDetailContent({
    required this.event,
    required this.available,
    super.key,
  });

  static const double _headerHeight = 200;

  final Event event;
  final AsyncValue<int> available;

  String _spotsLabel(AppLocalizations l10n) => available.when(
    data: (int a) => a <= 0
        ? l10n.common_sold_out
        : l10n.event_spots_available(a, event.capacity),
    loading: () => l10n.event_availability_loading,
    error: (_, _) => l10n.event_capacity_total(event.capacity),
  );

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool soldOut = (available.value ?? 1) <= 0;

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: _headerHeight,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Hero(
                    tag: eventImageHeroTag(event.id),
                    child: EventImage(
                      imageUrl: event.imageUrl,
                      height: _headerHeight,
                    ),
                  ),
                  const _TopScrim(),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(UiSpacing.large),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    event.title,
                    style: context.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: UiSpacing.small),
                  Wrap(
                    spacing: UiSpacing.small,
                    runSpacing: UiSpacing.extraSmall,
                    children: <Widget>[
                      UiChip(label: event.categoryName),
                      UiChip(
                        label: event.cityName,
                        icon: Icons.location_on_outlined,
                      ),
                    ],
                  ),
                  const SizedBox(height: UiSpacing.medium),
                  EventInfoRow(
                    icon: Icons.calendar_today_outlined,
                    text: formatEventDateTime(event.startsAt),
                  ),
                  const SizedBox(height: UiSpacing.small),
                  EventInfoRow(
                    icon: Icons.confirmation_num_outlined,
                    text: formatPrice(event.price, freeLabel: l10n.common_free),
                  ),
                  const SizedBox(height: UiSpacing.small),
                  EventInfoRow(
                    icon: Icons.people_outline,
                    text: _spotsLabel(l10n),
                  ),
                  const SizedBox(height: UiSpacing.large),
                  Text(
                    l10n.event_description_title,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: UiSpacing.extraSmall),
                  Text(event.description, style: context.textTheme.bodyLarge),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(UiSpacing.large),
          child: UiButton(
            label: soldOut ? l10n.common_sold_out : l10n.action_reserve,
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

/// Oscurece el borde superior de la imagen. Sin esto, el botón de volver
/// —que es blanco— desaparece sobre las fotos claras.
class _TopScrim extends StatelessWidget {
  const _TopScrim();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.center,
          colors: <Color>[Color(0x66000000), Color(0x00000000)],
        ),
      ),
    );
  }
}
