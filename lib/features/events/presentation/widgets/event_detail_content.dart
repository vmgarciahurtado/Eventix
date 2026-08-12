import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/core/helpers/date_format.dart';
import 'package:eventix/core/helpers/money_format.dart';
import 'package:eventix/core/l10n/app_localizations.dart';
import 'package:eventix/features/events/domain/entities/event.dart';
import 'package:eventix/features/events/presentation/widgets/event_image.dart';
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

  static const double _headerHeight = UiSizes.size200;

  final Event event;
  final AsyncValue<int> available;

  String _spotsLabel(AppLocalizations l10n) {
    return available.when(
      data: (int a) => a <= 0
          ? l10n.common_sold_out
          : l10n.event_spots_available(a, event.capacity),
      loading: () => l10n.event_availability_loading,
      error: (_, _) => l10n.event_capacity_total(event.capacity),
    );
  }

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
                  UiText(
                    event.title,
                    style: UiTextStyle.headline,
                    weight: FontWeight.bold,
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
                  UiIconText(
                    icon: Icons.calendar_today_outlined,
                    text: formatEventDateTime(event.startsAt),
                    size: UiSize.medium,
                    iconColor: context.colorScheme.primary,
                    textColor: context.colorScheme.onSurface,
                  ),
                  const SizedBox(height: UiSpacing.small),
                  UiIconText(
                    icon: Icons.confirmation_num_outlined,
                    text: formatPrice(event.price, freeLabel: l10n.common_free),
                    size: UiSize.medium,
                    iconColor: context.colorScheme.primary,
                    textColor: context.colorScheme.onSurface,
                  ),
                  const SizedBox(height: UiSpacing.small),
                  UiIconText(
                    icon: Icons.people_outline,
                    text: _spotsLabel(l10n),
                    size: UiSize.medium,
                    iconColor: context.colorScheme.primary,
                    textColor: context.colorScheme.onSurface,
                  ),
                  const SizedBox(height: UiSpacing.large),
                  UiText(
                    l10n.event_description_title,
                    style: UiTextStyle.subtitle,
                    weight: FontWeight.bold,
                  ),
                  const SizedBox(height: UiSpacing.extraSmall),
                  UiText(event.description),
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

  /// Opacidad del velo en el borde superior, donde va el botón de volver.
  static const double _veil = 0.4;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.center,
          colors: <Color>[
            UiColors.black.withValues(alpha: _veil),
            UiColors.black.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }
}
