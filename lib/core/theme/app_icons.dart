import 'package:eventix/features/app_config/domain/enums/app_icon.dart';
import 'package:flutter/material.dart';

/// Traduce el catálogo de iconos del JSON a los `IconData` de Material.
///
/// El `switch` es exhaustivo a propósito: agregar un valor a [AppIcon] sin
/// darle icono rompe la compilación en vez de pintar un cuadro vacío.
abstract final class AppIcons {
  static IconData of(AppIcon icon) => switch (icon) {
    AppIcon.explore => Icons.explore_outlined,
    AppIcon.filter => Icons.filter_alt_outlined,
    AppIcon.ticket => Icons.confirmation_num_outlined,
    AppIcon.party => Icons.celebration_outlined,
    AppIcon.music => Icons.music_note_outlined,
    AppIcon.calendar => Icons.event_outlined,
    AppIcon.location => Icons.location_city_outlined,
    AppIcon.star => Icons.star_outline,
  };
}
