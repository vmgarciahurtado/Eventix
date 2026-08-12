import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/core/helpers/date_format.dart';
import 'package:eventix/core/helpers/money_format.dart';
import 'package:eventix/core/l10n/app_localizations.dart';
import 'package:eventix/features/events/domain/entities/event.dart';
import 'package:eventix/features/events/presentation/widgets/event_image.dart';
import 'package:flutter/material.dart';

/// Evento dentro del catálogo: foto con categoría y precio encima, y debajo
/// el título con ciudad y fecha.
class EventCard extends StatelessWidget {
  const EventCard({required this.event, required this.onTap, super.key});

  /// Alto de la foto de portada. Suficiente para reconocer el evento sin que
  /// la tarjeta desplace al resto del listado.
  static const double _coverHeight = UiSizes.size120;

  final Event event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return UiCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _Cover(event: event),
          Padding(
            padding: const EdgeInsets.all(UiSpacing.medium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                UiText(
                  event.title,
                  style: UiTextStyle.subtitle,
                  maxLines: 1,
                ),
                const SizedBox(height: UiSpacing.small),
                UiIconText(
                  icon: Icons.location_on_outlined,
                  text: event.cityName,
                  maxLines: 1,
                ),
                const SizedBox(height: UiSpacing.extraSmall),
                UiIconText(
                  icon: Icons.calendar_today_outlined,
                  text: formatEventDateTime(event.startsAt),
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Cover extends StatelessWidget {
  const _Cover({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Hero(
          tag: eventImageHeroTag(event.id),
          child: EventImage(
            imageUrl: event.imageUrl,
            height: EventCard._coverHeight,
          ),
        ),
        Positioned(
          top: UiSpacing.small,
          left: UiSpacing.small,
          child: UiTag(label: event.categoryName, onImage: true),
        ),
        Positioned(
          top: UiSpacing.small,
          right: UiSpacing.small,
          child: UiTag(
            label: formatPrice(
              event.price,
              freeLabel: AppLocalizations.of(context).common_free,
            ),
            onImage: true,
          ),
        ),
      ],
    );
  }
}
