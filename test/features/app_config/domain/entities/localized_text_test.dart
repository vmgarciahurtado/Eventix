import 'package:eventix/features/app_config/domain/entities/localized_text.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const LocalizedText text = LocalizedText(<String, String>{
    'es': 'Hola',
    'en': 'Hi',
  });

  group('resolve', () {
    test('devuelve el idioma pedido', () {
      expect(text.resolve('en'), 'Hi');
    });

    test('un idioma que no está cae al base', () {
      expect(text.resolve('pt'), 'Hola');
    });

    test('sin el idioma base toma el primero que haya', () {
      const LocalizedText only = LocalizedText(<String, String>{'fr': 'Salut'});

      expect(only.resolve('en'), 'Salut');
    });

    test('sin traducciones devuelve vacío en vez de null', () {
      expect(LocalizedText.empty.resolve('es'), '');
    });
  });

  group('igualdad', () {
    test('dos textos con las mismas traducciones son iguales', () {
      expect(
        text,
        const LocalizedText(<String, String>{'en': 'Hi', 'es': 'Hola'}),
      );
      expect(
        text.hashCode,
        const LocalizedText(<String, String>{'en': 'Hi', 'es': 'Hola'})
            .hashCode,
      );
    });

    test('cambiar una traducción los separa', () {
      expect(
        text,
        isNot(const LocalizedText(<String, String>{'es': 'Hola', 'en': 'Yo'})),
      );
    });

    test('sobrar un idioma también los separa', () {
      expect(text, isNot(const LocalizedText(<String, String>{'es': 'Hola'})));
    });

    test('no es igual a otro tipo', () {
      expect(text, isNot('Hola'));
    });

    test('toString muestra las traducciones', () {
      expect(text.toString(), contains('Hola'));
    });
  });
}
