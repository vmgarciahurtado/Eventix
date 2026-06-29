import 'package:intl/intl.dart';

/// Formatea un precio en pesos colombianos, ej: "\$80.000". Si es 0, "Gratis".
String formatPrice(double value) {
  if (value <= 0) return 'Gratis';
  return NumberFormat.currency(
    locale: 'es_CO',
    symbol: r'$',
    decimalDigits: 0,
  ).format(value);
}
