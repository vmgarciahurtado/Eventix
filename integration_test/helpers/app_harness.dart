import 'package:eventix/core/env/env.dart';
import 'package:eventix/core/router/app_router.dart';
import 'package:eventix/features/app_config/di/app_config_di.dart';
import 'package:eventix/features/app_config/domain/entities/app_config.dart';
import 'package:eventix/features/app_config/presentation/providers/app_config_provider.dart';
import 'package:eventix/main.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'test_credentials.dart';

/// Arranque de la app real contra el Supabase real. Es lo que distingue estas
/// pruebas de las de widget: acá nada está simulado, así que lo que pasa aquí
/// es lo que le va a pasar al usuario.

bool _initialized = false;
AppConfig _config = AppConfig.fallback;

/// Replica el arranque de `main()`. Idempotente: `main_test.dart` lo llama una
/// vez, pero correr un archivo suelto no debe romperse por eso.
Future<void> bootstrapApp() async {
  if (_initialized) return;
  await dotenv.load();
  if (Env.supabaseUrl.isEmpty || Env.supabasePublishableKey.isEmpty) {
    throw StateError(
      'Falta el archivo .env en la raíz del proyecto: sin él la app no puede '
      'hablar con Supabase y estas pruebas no tienen sentido.',
    );
  }
  await initializeDateFormatting('es');
  await Supabase.initialize(
    url: Env.supabaseUrl,
    publishableKey: Env.supabasePublishableKey,
  );
  _config = await loadStartupAppConfig();
  _initialized = true;
}

/// Monta la app completa y espera a que el splash resuelva a dónde ir.
///
/// Cada `testWidgets` destruye el árbol al terminar, así que TODA prueba tiene
/// que montar la app de nuevo: no se hereda la pantalla de la prueba anterior.
Future<void> launchApp(WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[appConfigOverride(_config)],
      child: const MainApp(),
    ),
  );
  await settle(tester);
}

/// El `pumpAndSettle` normal se rinde con animaciones en curso o respuestas de
/// red lentas; acá se bombea por tiempo, que es lo que aguanta una red real.
Future<void> settle(
  WidgetTester tester, {
  Duration timeout = const Duration(seconds: 10),
}) async {
  final DateTime deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    await tester.pump(const Duration(milliseconds: 100));
    if (!tester.binding.hasScheduledFrame) return;
  }
}

/// Monta la app y la deja en [location].
///
/// El `appRouter` es global y conserva su ubicación entre pruebas, pero el
/// árbol de widgets no: hay que montar y después navegar. Cada tramo declara
/// desde dónde arranca en vez de asumir dónde lo dejó el anterior.
Future<void> launchAt(WidgetTester tester, String location) async {
  await tester.pumpWidget(const ProviderScope(child: MainApp()));
  appRouter.go(location);
  await settle(tester);
}

/// Cierra la sesión si hay una abierta, para que el flujo de autenticación
/// empiece siempre desde el mismo estado.
Future<void> clearSession() async {
  if (hasSession) await Supabase.instance.client.auth.signOut();
}

/// Abre sesión por API, sin pasar por la pantalla.
///
/// El login por UI se prueba en `login/`; los demás tramos no deberían caerse
/// si ese falló, ni depender de que haya corrido antes.
Future<void> ensureSignedIn() async {
  if (hasSession) return;
  await Supabase.instance.client.auth.signInWithPassword(
    email: TestCredentials.email,
    password: TestCredentials.password,
  );
}

bool get hasSession => Supabase.instance.client.auth.currentSession != null;
