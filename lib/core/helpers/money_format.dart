import 'package:intl/intl.dart';

/// Formatea un precio en pesos colombianos, ej: "\$80.000". Si es 0, devuelve
/// [freeLabel] (por defecto "Gratis"; pásalo localizado desde presentación).
String formatPrice(double value, {String freeLabel = 'Gratis'}) {
  if (value <= 0) return freeLabel;
  return NumberFormat.currency(
    locale: 'es_CO',
    symbol: r'$',
    decimalDigits: 0,
    // El patrón de es_CO pone el símbolo detrás ("80.000 $"), que no es como
    // se escriben los pesos acá. Se fija el orden y se deja que el locale
    // siga decidiendo el separador de miles.
    customPattern: '¤#,##0',
  ).format(value);
}
