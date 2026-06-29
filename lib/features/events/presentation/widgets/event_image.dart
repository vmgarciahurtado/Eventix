import 'package:eventix/features/events/presentation/widgets/category_visuals.dart';
import 'package:flutter/material.dart';

/// Imagen de un evento. Intenta cargar el asset local
/// `assets/images/event_<imageKey>.jpg`; si no existe, cae a un degradado con
/// el ícono de la categoría (para no depender de imágenes remotas).
class EventImage extends StatelessWidget {
  const EventImage({
    required this.imageKey,
    required this.categoryName,
    required this.height,
    this.iconSize = 56,
    super.key,
  });

  final String? imageKey;
  final String categoryName;
  final double height;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final CategoryVisual visual = categoryVisual(categoryName);
    final Widget fallback = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: visual.colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(visual.icon, size: iconSize, color: Colors.white),
      ),
    );

    final String? key = imageKey;
    final Widget content = (key == null || key.isEmpty)
        ? fallback
        : Image.asset(
            'assets/images/event_$key.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: height,
            errorBuilder: (BuildContext _, Object __, StackTrace? ___) =>
                fallback,
          );

    return SizedBox(height: height, width: double.infinity, child: content);
  }
}
