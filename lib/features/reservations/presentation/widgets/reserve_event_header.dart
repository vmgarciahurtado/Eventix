import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/core/helpers/date_format.dart';
import 'package:eventix/core/l10n/app_localizations.dart';
import 'package:eventix/features/events/domain/entities/event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Título, fecha y disponibilidad del evento que se va a reservar.
class ReserveEventHeader extends StatelessWidget {
  const ReserveEventHeader({
    required this.event,
    required this.available,
    super.key,
  });

  final Event event;
  final AsyncValue<int> available;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool soldOut = (available.value ?? 1) <= 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          event.title,
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: UiSpacing.extraSmall),
        Text(
          formatEventDateTime(event.startsAt),
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: UiSpacing.extraSmall),
        Text(
          _availabilityLabel(l10n),
          style: context.textTheme.bodyMedium?.copyWith(
            color: soldOut
                ? context.colorScheme.error
                : context.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  String _availabilityLabel(AppLocalizations l10n) => available.when(
    data: (int a) => a <= 0
        ? l10n.reserve_sold_out_label
        : l10n.event_spots_available(a, event.capacity),
    loading: () => l10n.reserve_availability_loading,
    error: (_, _) => l10n.reserve_spots_total(event.capacity),
  );
}
