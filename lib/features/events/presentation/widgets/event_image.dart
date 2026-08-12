import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:flutter/material.dart';

/// Etiqueta que enlaza la imagen de la tarjeta con la del detalle para que
/// Flutter anime la transición entre las dos pantallas.
String eventImageHeroTag(String eventId) => 'event-image-$eventId';

/// Imagen de un evento, tomada de la URL que manda el backend. Si no hay URL o
/// la descarga falla, muestra el marcador de "sin imagen".
class EventImage extends StatelessWidget {
  const EventImage({
    required this.imageUrl,
    required this.height,
    super.key,
  });

  final String? imageUrl;
  final double height;

  @override
  Widget build(BuildContext context) {
    final String? url = imageUrl;
    final Widget content = (url == null || url.isEmpty)
        ? _NoImage(height: height)
        : Image.network(
            url,
            fit: BoxFit.cover,
            width: double.infinity,
            height: height,
            // Mientras baja se deja el fondo liso: el marcador significa "no
            // hay imagen", y mostrarlo antes de tiempo diría algo falso.
            loadingBuilder:
                (BuildContext _, Widget child, ImageChunkEvent? progress) =>
                    progress == null ? child : const _Placeholder(),
            errorBuilder: (BuildContext _, Object __, StackTrace? ___) =>
                _NoImage(height: height),
          );

    return SizedBox(height: height, width: double.infinity, child: content);
  }
}

/// Fondo liso que ocupa el hueco de la imagen sin afirmar nada.
class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(color: context.colorScheme.surfaceContainerHighest);
  }
}

/// Marcador de "sin imagen". El PNG es un glifo negro, así que se tiñe: sobre
/// el fondo oscuro de la app sería invisible tal cual viene.
class _NoImage extends StatelessWidget {
  const _NoImage({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.colorScheme.surfaceContainerHighest,
      child: Center(
        child: Image.asset(
          'assets/images/no_image.png',
          height: height * 0.35,
          color: context.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
