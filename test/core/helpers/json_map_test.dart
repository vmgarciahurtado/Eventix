import 'package:eventix/core/helpers/json_map.dart';
import 'package:flutter_test/flutter_test.dart';

/// La regla de la casa: un campo con el tipo equivocado se lee como si no
/// estuviera, nunca lanza.
void main() {
  const JsonMap json = JsonMap(<String, Object?>{
    'titulo': 'Eventix',
    'activo': true,
    'version': 2,
    'marca': <String, Object?>{'color': '#FFFFFF'},
    'bloques': <Object?>['banner', 1, '', '  ', 'events'],
    'laminas': <Object?>[
      <String, Object?>{'icon': 'explore'},
      'no soy un objeto',
    ],
    'texto': <String, Object?>{'es': 'Hola', 'en': 'Hi', 'roto': 7},
  });

  group('escalares', () {
    test('lee el valor cuando el tipo coincide', () {
      expect(json.string('titulo'), 'Eventix');
      expect(json.boolean('activo', fallback: false), isTrue);
      expect(json.integer('version', fallback: 1), 2);
    });

    test('un tipo equivocado cae al respaldo', () {
      expect(json.string('version', fallback: 'x'), 'x');
      expect(json.boolean('titulo', fallback: true), isTrue);
      expect(json.integer('titulo', fallback: 9), 9);
    });

    test('una clave ausente cae al respaldo', () {
      expect(json.string('nada'), '');
      expect(json.boolean('nada', fallback: true), isTrue);
      expect(json.integer('nada', fallback: 9), 9);
    });
  });

  group('anidados', () {
    test('devuelve el objeto hijo', () {
      expect(json.child('marca').string('color'), '#FFFFFF');
    });

    test('un hijo que no es objeto se lee vacío en vez de romper', () {
      expect(json.child('titulo').isEmpty, isTrue);
      expect(json.child('titulo').string('color'), '');
    });

    test('las listas de objetos descartan lo que no lo sea', () {
      expect(json.children('laminas'), hasLength(1));
      expect(json.children('laminas').first.string('icon'), 'explore');
    });

    test('pedir hijos de algo que no es lista da una lista vacía', () {
      expect(json.children('titulo'), isEmpty);
    });
  });

  group('listas de texto', () {
    test('descarta lo que no sea texto con contenido', () {
      expect(json.strings('bloques'), <String>['banner', 'events']);
    });

    test('lo que no es lista da una lista vacía', () {
      expect(json.strings('marca'), isEmpty);
    });
  });

  group('mapas de texto', () {
    test('conserva solo las entradas de texto', () {
      expect(json.stringMap('texto'), <String, String>{
        'es': 'Hola',
        'en': 'Hi',
      });
    });

    test('lo que no es objeto da un mapa vacío', () {
      expect(json.stringMap('bloques'), isEmpty);
    });
  });

  group('construcción', () {
    test('envolver algo que no es objeto da un mapa vacío', () {
      expect(JsonMap.of(null).isEmpty, isTrue);
      expect(JsonMap.of(<Object?>[1, 2]).isEmpty, isTrue);
      expect(JsonMap.of('texto').isEmpty, isTrue);
    });

    test('envolver un objeto lo conserva', () {
      const JsonMap wrapped = JsonMap(<String, Object?>{'a': 1});

      expect(wrapped.integer('a', fallback: 0), 1);
    });

    test('has distingue una clave nula de una ausente', () {
      const JsonMap nullable = JsonMap(<String, Object?>{'a': null});

      expect(nullable.has('a'), isTrue);
      expect(nullable.has('b'), isFalse);
    });
  });
}
