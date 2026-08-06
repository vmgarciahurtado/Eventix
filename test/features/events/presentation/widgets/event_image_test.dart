import 'package:eventix/features/events/presentation/widgets/event_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';

/// El marcador de "sin imagen" distingue los tres estados del widget.
Finder get _noImage => find.byWidgetPredicate(
  (Widget widget) =>
      widget is Image &&
      widget.image is AssetImage &&
      (widget.image as AssetImage).assetName == 'assets/images/no_image.png',
);

Finder get _networkImage => find.byWidgetPredicate(
  (Widget widget) => widget is Image && widget.image is NetworkImage,
);

void main() {
  testWidgets('sin URL muestra el marcador de sin imagen', (
    WidgetTester tester,
  ) async {
    await pumpComponent(
      tester,
      const EventImage(imageUrl: null, height: 120),
    );

    expect(_noImage, findsOneWidget);
    expect(_networkImage, findsNothing);
  });

  testWidgets('una URL vacía cuenta como sin imagen', (
    WidgetTester tester,
  ) async {
    await pumpComponent(tester, const EventImage(imageUrl: '', height: 120));

    expect(_noImage, findsOneWidget);
  });

  testWidgets('con URL intenta descargarla en vez de mostrar el marcador', (
    WidgetTester tester,
  ) async {
    await pumpComponent(
      tester,
      const EventImage(imageUrl: 'https://cdn.test/foto.jpg', height: 120),
    );

    expect(_networkImage, findsOneWidget);
    // Mientras baja no se muestra el marcador: diría algo que aún no se sabe.
    expect(_noImage, findsNothing);
  });

  testWidgets('mientras baja pinta un fondo liso, no el marcador', (
    WidgetTester tester,
  ) async {
    await pumpComponent(
      tester,
      const EventImage(imageUrl: 'https://cdn.test/foto.jpg', height: 120),
    );

    // El cliente HTTP de pruebas no emite progreso: se invoca a mano.
    final Image image = tester.widget<Image>(_networkImage);
    await pumpComponent(
      tester,
      image.loadingBuilder!(
        tester.element(find.byType(Scaffold)),
        const SizedBox.shrink(),
        const ImageChunkEvent(
          cumulativeBytesLoaded: 10,
          expectedTotalBytes: 100,
        ),
      ),
    );

    expect(find.byType(ColoredBox), findsWidgets);
    expect(_noImage, findsNothing);
  });

  testWidgets('si la descarga falla cae al marcador', (
    WidgetTester tester,
  ) async {
    // El cliente HTTP de pruebas responde 400, así que corre el errorBuilder.
    await pumpComponent(
      tester,
      const EventImage(imageUrl: 'https://cdn.test/roto.jpg', height: 120),
    );
    await tester.pumpAndSettle();

    expect(_noImage, findsOneWidget);
  });

  testWidgets('respeta la altura que le pide la tarjeta', (
    WidgetTester tester,
  ) async {
    await pumpComponent(
      tester,
      const EventImage(imageUrl: null, height: 200),
    );

    expect(tester.getSize(find.byType(EventImage)).height, 200);
  });

  test('el tag del Hero es único por evento', () {
    expect(eventImageHeroTag('evt-1'), isNot(eventImageHeroTag('evt-2')));
    expect(eventImageHeroTag('evt-1'), 'event-image-evt-1');
  });
}
