import 'dart:async';

import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/core/l10n/app_localizations.dart';
import 'package:eventix/features/events/presentation/pages/events_page.dart';
import 'package:eventix/features/reservations/presentation/pages/my_reservations_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Cierre del flujo de compra.
class ReservationConfirmedPage extends StatelessWidget {
  static const String routePath = '/reservation-confirmed';

  const ReservationConfirmedPage({super.key});

  static const double _badgeSize = 96;
  static const double _glowTint = 0.28;
  static const double _glowSpread = 28;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Color success = context.statusColors.success;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(UiSpacing.extraLarge),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Center(
                  child: Container(
                    width: _badgeSize,
                    height: _badgeSize,
                    decoration: BoxDecoration(
                      color: success,
                      shape: BoxShape.circle,
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: success.withValues(alpha: _glowTint),
                          blurRadius: _glowSpread,
                          spreadRadius: _glowSpread / 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: UiIconSize.extraLarge,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: UiSpacing.extraLarge),
                Text.rich(
                  TextSpan(
                    children: <InlineSpan>[
                      TextSpan(text: '${l10n.confirmed_title_lead} '),
                      TextSpan(
                        text: l10n.confirmed_title_highlight.toUpperCase(),
                        style: TextStyle(color: success),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  style: context.textTheme.displaySmall,
                ),
                const SizedBox(height: UiSpacing.medium),
                Text(
                  l10n.confirmed_message,
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: UiSpacing.extraExtraLarge),
                UiButton(
                  label: l10n.confirmed_go_to_reservations,
                  icon: Icons.confirmation_num_outlined,
                  expanded: true,
                  onPressed: () => _goToReservations(context),
                ),
                const SizedBox(height: UiSpacing.medium),
                UiButton(
                  label: l10n.confirmed_go_to_events,
                  variant: UiButtonVariant.outline,
                  expanded: true,
                  onPressed: () => context.go(EventsPage.routePath),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Reconstruye el catálogo como raíz antes de apilar las reservas: con un
  /// `go` directo, esa pantalla quedaría sola y el back cerraría la app.
  void _goToReservations(BuildContext context) {
    context.go(EventsPage.routePath);
    unawaited(context.push(MyReservationsPage.routePath));
  }
}
