import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/core/helpers/date_format.dart';
import 'package:eventix/core/l10n/app_localizations.dart';
import 'package:eventix/features/reservations/domain/entities/reservation.dart';
import 'package:eventix/features/reservations/domain/enums/reservation_status.dart';
import 'package:flutter/material.dart';

class ReservationCard extends StatelessWidget {
  const ReservationCard({required this.reservation, super.key});

  final Reservation reservation;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: UiSpacing.medium),
      child: Padding(
        padding: const EdgeInsets.all(UiSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    reservation.eventTitle,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _StatusPill(status: reservation.status),
              ],
            ),
            const SizedBox(height: UiSpacing.small),
            _IconText(
              icon: Icons.people_outline,
              text: l10n.reservation_quantity(reservation.quantity),
            ),
            if (reservation.eventStartsAt != null) ...<Widget>[
              const SizedBox(height: UiSpacing.extraSmall),
              _IconText(
                icon: Icons.calendar_today_outlined,
                text: formatEventDateTime(reservation.eventStartsAt!),
              ),
            ],
            const SizedBox(height: UiSpacing.extraSmall),
            _IconText(
              icon: Icons.event_available_outlined,
              text: l10n.reservation_reserved_on(
                formatEventDay(reservation.createdAt),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  static const double _tint = 0.15;

  final ReservationStatus status;

  @override
  Widget build(BuildContext context) {
    final Color color = status == ReservationStatus.confirmed
        ? context.statusColors.success
        : context.statusColors.warning;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: UiSpacing.small,
        vertical: UiSpacing.extraExtraSmall,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: _tint),
        borderRadius: UiRadius.borderFull,
      ),
      child: Text(
        status.label,
        style: context.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _IconText extends StatelessWidget {
  const _IconText({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon, size: 16, color: context.colorScheme.onSurfaceVariant),
        const SizedBox(width: UiSpacing.extraSmall),
        Expanded(
          child: Text(
            text,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
