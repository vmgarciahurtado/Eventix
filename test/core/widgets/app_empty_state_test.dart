import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/core/widgets/app_character.dart';
import 'package:eventix/core/widgets/app_empty_state.dart';
import 'package:eventix/core/widgets/app_icon_badge.dart';
import 'package:eventix/core/widgets/app_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('AppEmptyState', () {
    testWidgets('usa la mascota, no un ícono genérico', (
      WidgetTester tester,
    ) async {
      await pumpComponent(
        tester,
        const AppEmptyState(title: 'Sin eventos', message: 'Vuelve luego.'),
      );

      expect(find.byType(AppCharacter), findsOneWidget);
      expect(find.text('Vuelve luego.'), findsOneWidget);
    });

    testWidgets('el título va en mayúsculas con la última palabra resaltada', (
      WidgetTester tester,
    ) async {
      await pumpComponent(
        tester,
        const AppEmptyState(title: 'Sin eventos', message: 'Vuelve luego.'),
      );

      expect(
        find.textContaining('SIN EVENTOS', findRichText: true),
        findsOneWidget,
      );
    });

    testWidgets('un título de una sola palabra no rompe el resaltado', (
      WidgetTester tester,
    ) async {
      await pumpComponent(
        tester,
        const AppEmptyState(title: 'Vacío', message: 'Nada por aquí.'),
      );

      expect(find.textContaining('VACÍO', findRichText: true), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('la acción es opcional', (WidgetTester tester) async {
      await pumpComponent(
        tester,
        const AppEmptyState(title: 'Sin eventos', message: 'Vuelve luego.'),
      );
      expect(find.byType(UiButton), findsNothing);

      await pumpComponent(
        tester,
        const AppEmptyState(
          title: 'Sin eventos',
          message: 'Vuelve luego.',
          action: UiButton(label: 'Explorar'),
        ),
      );
      expect(find.widgetWithText(UiButton, 'Explorar'), findsOneWidget);
    });
  });

  group('widgets de marca', () {
    testWidgets('solo se usan los dos assets de marca permitidos', (
      WidgetTester tester,
    ) async {
      await pumpComponent(
        tester,
        const Column(
          children: <Widget>[AppLogo(width: 200), AppIconBadge(size: 44)],
        ),
      );

      final List<String> assets = tester
          .widgetList<Image>(find.byType(Image))
          .map((Image image) => (image.image as AssetImage).assetName)
          .toList();

      expect(assets, <String>[
        'assets/images/logo.png',
        'assets/images/app_icon.png',
      ]);
    });

    testWidgets('el lockup se dimensiona por ancho', (
      WidgetTester tester,
    ) async {
      await pumpComponent(tester, const AppLogo(width: 220));

      expect(tester.widget<Image>(find.byType(Image)).width, 220);
    });

    testWidgets('el chip del icono es cuadrado y con esquinas redondeadas', (
      WidgetTester tester,
    ) async {
      await pumpComponent(tester, const AppIconBadge(size: 44));

      expect(tester.getSize(find.byType(AppIconBadge)), const Size(44, 44));
      expect(find.byType(ClipRRect), findsOneWidget);
    });

    testWidgets('si falta la mascota la pantalla no se rompe', (
      WidgetTester tester,
    ) async {
      await pumpComponent(tester, const AppCharacter(height: 180));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
