import 'package:intl/intl.dart';

/// Formatea fecha y hora de un evento en español, ej: "vie 4 jul · 8:00 p. m.".
String formatEventDateTime(DateTime dt) =>
    DateFormat('EEE d MMM · h:mm a', 'es').format(dt.toLocal());

/// Formatea solo la fecha, ej: "4 jul 2026".
String formatEventDay(DateTime dt) =>
    DateFormat('d MMM yyyy', 'es').format(dt.toLocal());
