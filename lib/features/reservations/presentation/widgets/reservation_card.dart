import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/core/helpers/date_format.dart';
import 'package:eventix/core/l10n/app_localizations.dart';
import 'package:eventix/features/reservations/domain/entities/reservation.dart';
import 'package:eventix/features/reservations/domain/enums/reservation_status.dart';
import 'package:flutter/material.dart';

/// Reserva dentro del listado del usuario: evento, estado y sus datos.
class ReservationCard extends StatelessWidget {
  const ReservationCard({required this.reservation, super.key});

  final Reservation reservation;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return UiCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: UiText(
                  reservation.eventTitle,
                  style: UiTextStyle.subtitle,
                ),
              ),
              UiTag(
                label: reservation.status.label,
                color: reservation.status == ReservationStatus.confirmed
                    ? context.statusColors.success
                    : context.statusColors.warning,
              ),
            ],
          ),
          const SizedBox(height: UiSpacing.small),
          UiIconText(
            icon: Icons.people_outline,
            text: l10n.reservation_quantity(reservation.quantity),
          ),
          if (reservation.eventStartsAt != null) ...<Widget>[
            const SizedBox(height: UiSpacing.extraSmall),
            UiIconText(
              icon: Icons.calendar_today_outlined,
              text: formatEventDateTime(reservation.eventStartsAt!),
            ),
          ],
          const SizedBox(height: UiSpacing.extraSmall),
          UiIconText(
            icon: Icons.event_available_outlined,
            text: l10n.reservation_reserved_on(
              formatEventDay(reservation.createdAt),
            ),
          ),
        ],
      ),
    );
  }
}
