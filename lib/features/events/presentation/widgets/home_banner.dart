import 'dart:async';

import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/core/extensions/localized_text_extension.dart';
import 'package:eventix/core/theme/app_icons.dart';
import 'package:eventix/features/app_config/domain/entities/banner_config.dart';
import 'package:eventix/features/app_config/domain/enums/banner_target.dart';
import 'package:eventix/features/app_config/presentation/providers/app_config_provider.dart';
import 'package:eventix/features/events/presentation/pages/events_page.dart';
import 'package:eventix/features/reservations/presentation/pages/my_reservations_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Ruta de cada destino del banner, o null cuando no hay a dónde ir. Los
/// destinos son un enum y no rutas libres, así que el JSON no puede mandar la
/// app a una ruta que no existe.
String? bannerTargetPath(BannerTarget target) => switch (target) {
  BannerTarget.none => null,
  BannerTarget.events => EventsPage.routePath,
  BannerTarget.reservations => MyReservationsPage.routePath,
};

/// Banner promocional de la pantalla de eventos: todo su contenido sale del
/// JSON y desaparece si el archivo lo apaga.
class HomeBanner extends ConsumerWidget {
  const HomeBanner({super.key});

  static const double _iconBoxSize = 48;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final BannerConfig banner = ref.watch(appConfigProvider).home.banner;
    if (!banner.enabled) return const SizedBox.shrink();

    final ColorScheme scheme = context.colorScheme;
    final BannerActionConfig? action = banner.action;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        UiSpacing.medium,
        UiSpacing.medium,
        UiSpacing.medium,
        0,
      ),
      child: Container(
        padding: const EdgeInsets.all(UiSpacing.medium),
        decoration: BoxDecoration(
          color: scheme.primary,
          borderRadius: UiRadius.borderLarge,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: _iconBoxSize,
              height: _iconBoxSize,
              decoration: BoxDecoration(
                color: scheme.secondary,
                borderRadius: UiRadius.borderMedium,
              ),
              child: Icon(
                AppIcons.of(banner.icon),
                color: scheme.onSecondary,
                size: UiIconSize.medium,
              ),
            ),
            const SizedBox(width: UiSpacing.medium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    banner.title.of(context).toUpperCase(),
                    style: context.textTheme.titleMedium?.copyWith(
                      color: scheme.onPrimary,
                    ),
                  ),
                  const SizedBox(height: UiSpacing.extraExtraSmall),
                  Text(
                    banner.subtitle.of(context),
                    style: context.textTheme.bodySmall?.copyWith(
                      color: scheme.onPrimary,
                    ),
                  ),
                  if (action != null) ...<Widget>[
                    const SizedBox(height: UiSpacing.small),
                    // Botón propio y no `UiButton`: sobre el color primario
                    // los estilos del kit se pintarían con ese mismo color.
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: scheme.onPrimary,
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () => _go(context, action.target),
                      child: Text(action.label.of(context)),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _go(BuildContext context, BannerTarget target) {
    final String? path = bannerTargetPath(target);
    if (path == null) return;
    // El catálogo ya está debajo: se reemplaza en vez de apilar otra copia.
    if (target == BannerTarget.events) {
      context.go(path);
    } else {
      unawaited(context.push(path));
    }
  }
}
