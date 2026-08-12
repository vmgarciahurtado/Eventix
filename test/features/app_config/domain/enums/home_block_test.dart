import 'package:eventix/features/app_config/domain/enums/home_block.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reconoce los nombres de los bloques', () {
    expect(HomeBlock.tryParse('banner'), HomeBlock.banner);
    expect(HomeBlock.tryParse('filters'), HomeBlock.filters);
    expect(HomeBlock.tryParse('events'), HomeBlock.events);
  });

  test('un nombre desconocido no inventa un bloque', () {
    expect(HomeBlock.tryParse('carrusel'), isNull);
    expect(HomeBlock.tryParse(null), isNull);
  });

  test('el orden por defecto trae los tres bloques', () {
    expect(HomeBlock.fallback, HomeBlock.values);
  });

  test('el bloque obligatorio es la lista de eventos', () {
    expect(HomeBlock.mandatory, HomeBlock.events);
  });
}
