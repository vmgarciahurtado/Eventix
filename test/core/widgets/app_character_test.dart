import 'package:eventix/core/widgets/app_character.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

/// Bundle que falla en todo: así se fuerza el camino de "el asset no está".
class _BrokenAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async =>
      throw FlutterError('asset no disponible: $key');
}

void main() {
  const double height = 120;

  testWidgets('pinta la mascota cuando el asset carga', (
    WidgetTester tester,
  ) async {
    await pumpComponent(tester, const AppCharacter(height: height));

    expect(find.byType(Image), findsOneWidget);
    expect(tester.getSize(find.byType(Image)).height, height);
  });

  testWidgets('si el asset falta reserva el alto y no rompe la pantalla', (
    WidgetTester tester,
  ) async {
    await pumpComponent(
      tester,
      DefaultAssetBundle(
        bundle: _BrokenAssetBundle(),
        child: const AppCharacter(height: height),
      ),
    );
    await tester.pumpAndSettle();

    // Colapsar a cero movería todo lo que hay debajo.
    expect(tester.takeException(), isNull);
    expect(
      tester.getSize(find.byType(AppCharacter)).height,
      height,
    );
  });
}
