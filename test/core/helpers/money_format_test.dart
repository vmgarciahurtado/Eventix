import 'package:eventix/core/helpers/money_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formatea pesos colombianos sin decimales y con punto de miles', () {
    expect(formatPrice(80000), r'$80.000');
    expect(formatPrice(1500000), r'$1.500.000');
    expect(formatPrice(1), r'$1');
  });

  test('redondea los centavos en vez de mostrarlos', () {
    expect(formatPrice(80000.4), r'$80.000');
    expect(formatPrice(80000.6), r'$80.001');
  });

  test('un precio en cero es "gratis", no "\$0"', () {
    expect(formatPrice(0), 'Gratis');
    expect(formatPrice(0, freeLabel: 'Free'), 'Free');
  });

  test('un precio negativo también cae en gratis y nunca imprime el signo', () {
    // Mostrar "-$5.000" sería peor que mostrar "Gratis".
    expect(formatPrice(-5000), 'Gratis');
  });
}
