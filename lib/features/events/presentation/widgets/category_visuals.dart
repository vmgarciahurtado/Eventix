import 'package:flutter/material.dart';

/// Ícono y degradado asociados a una categoría, para dar identidad visual a las
/// tarjetas de evento sin depender de imágenes remotas (todo local).
class CategoryVisual {
  const CategoryVisual(this.icon, this.colors);

  final IconData icon;
  final List<Color> colors;
}

CategoryVisual categoryVisual(String categoryName) {
  switch (categoryName.toLowerCase()) {
    case 'música':
      return const CategoryVisual(
        Icons.music_note_rounded,
        <Color>[Color(0xFF7C3AED), Color(0xFFDB2777)],
      );
    case 'tecnología':
      return const CategoryVisual(
        Icons.memory_rounded,
        <Color>[Color(0xFF2563EB), Color(0xFF0EA5A4)],
      );
    case 'deportes':
      return const CategoryVisual(
        Icons.sports_soccer_rounded,
        <Color>[Color(0xFF059669), Color(0xFF65A30D)],
      );
    case 'arte':
      return const CategoryVisual(
        Icons.palette_rounded,
        <Color>[Color(0xFFEA580C), Color(0xFFDB2777)],
      );
    case 'gastronomía':
      return const CategoryVisual(
        Icons.restaurant_rounded,
        <Color>[Color(0xFFD97706), Color(0xFFDC2626)],
      );
    default:
      return const CategoryVisual(
        Icons.event_rounded,
        <Color>[Color(0xFF4F46E5), Color(0xFF0EA5A4)],
      );
  }
}
