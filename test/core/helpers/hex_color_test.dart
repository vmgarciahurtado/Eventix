import 'package:eventix/core/helpers/hex_color.dart';
import 'package:flutter_test/flutter_test.dart';

/// Lo que puede escribir alguien editando el JSON a mano.
void main() {
  group('válidos', () {
    test('seis dígitos quedan opacos', () {
      expect(parseArgb('#F2F04B'), 0xFFF2F04B);
    });

    test('ocho dígitos conservan el alfa', () {
      expect(parseArgb('#80E64BC8'), 0x80E64BC8);
    });

    test('el numeral es opcional', () {
      expect(parseArgb('F2F04B'), 0xFFF2F04B);
    });

    test('no distingue mayúsculas y tolera espacios', () {
      expect(parseArgb('  #f2f04b  '), 0xFFF2F04B);
    });

    test('el negro no se confunde con un error', () {
      expect(parseArgb('#000000'), 0xFF000000);
    });
  });

  group('inválidos', () {
    test('null no es un color', () {
      expect(parseArgb(null), isNull);
    });

    test('vacío tampoco', () {
      expect(parseArgb(''), isNull);
    });

    test('con dígitos de menos', () {
      expect(parseArgb('#FFF'), isNull);
    });

    test('con letras fuera del hexadecimal', () {
      expect(parseArgb('#GGGGGG'), isNull);
    });

    test('un nombre de color no sirve', () {
      expect(parseArgb('amarillo'), isNull);
    });
  });
}
