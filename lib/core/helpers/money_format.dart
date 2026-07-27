import 'package:intl/intl.dart';

/// Formatea un precio en pesos colombianos, ej: "\$80.000". Si es 0, devuelve
/// [freeLabel] (por defecto "Gratis"; pásalo localizado desde presentación).
String formatPrice(double value, {String freeLabel = 'Gratis'}) {
  if (value <= 0) return freeLabel;
  return NumberFormat.currency(
    locale: 'es_CO',
    symbol: r'$',
    decimalDigits: 0,
  ).format(value);
}
