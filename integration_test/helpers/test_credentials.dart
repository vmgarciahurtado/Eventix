import 'package:flutter_test/flutter_test.dart';

/// Credenciales de la cuenta de prueba, inyectadas al compilar.
///
/// NUNCA van en el repositorio: se pasan con `--dart-define` al lanzar la
/// suite (ver docs/TESTING.md).
abstract final class TestCredentials {
  static const String email = String.fromEnvironment('EVENTIX_TEST_EMAIL');
  static const String password = String.fromEnvironment(
    'EVENTIX_TEST_PASSWORD',
  );

  static bool get areAvailable => email.isNotEmpty && password.isNotEmpty;
}

/// Corta la prueba con un motivo visible cuando no hay credenciales, en vez de
/// dejarla fallar con un mensaje que no explica nada.
///
/// ```dart
/// if (skipWithoutSession()) return;
/// ```
bool skipWithoutSession() {
  if (TestCredentials.areAvailable) return false;
  markTestSkipped(
    'Faltan --dart-define=EVENTIX_TEST_EMAIL y EVENTIX_TEST_PASSWORD: '
    'esta prueba necesita una cuenta real ya verificada.',
  );
  return true;
}
