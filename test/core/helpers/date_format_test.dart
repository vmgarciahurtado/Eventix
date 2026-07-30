import 'package:eventix/core/helpers/date_format.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() => initializeDateFormatting('es'));

  test('formatea fecha y hora del evento en español', () {
    // Se construye en local a propósito: el helper convierte con toLocal() y
    // pasar UTC ataría el resultado a la zona de quien corra la prueba.
    final DateTime dt = DateTime(2026, 7, 4, 20, 30);
    final String formatted = formatEventDateTime(dt);

    expect(formatted, contains('4 jul'));
    expect(formatted, contains('8:30'));
    expect(formatted, contains('·'));
  });

  test('el día de la semana sale en español, no en inglés', () {
    // 4 de julio de 2026 es sábado.
    expect(formatEventDateTime(DateTime(2026, 7, 4, 20)), startsWith('sáb'));
  });

  test('formatea solo el día con el año', () {
    expect(formatEventDay(DateTime(2026, 7, 4)), '4 jul 2026');
  });

  test('la hora usa formato de 12 con indicador de meridiano', () {
    expect(formatEventDateTime(DateTime(2026, 7, 4, 9)), contains('9:00'));
    expect(formatEventDateTime(DateTime(2026, 7, 4, 21)), contains('9:00'));
    expect(
      formatEventDateTime(DateTime(2026, 7, 4, 9)),
      isNot(formatEventDateTime(DateTime(2026, 7, 4, 21))),
    );
  });
}
