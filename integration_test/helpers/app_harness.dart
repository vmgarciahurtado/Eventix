import 'package:eventix/core/env/env.dart';
import 'package:eventix/core/router/app_router.dart';
import 'package:eventix/main.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Arranque de la app real contra el Supabase real. Es lo que distingue estas
/// pruebas de las de widget: acá nada está simulado, así que lo que pasa aquí
/// es lo que le va a pasar al usuario.

bool _initialized = false;

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
  _initialized = true;
}

/// Monta la app completa y espera a que el splash resuelva a dónde ir.
Future<void> launchApp(WidgetTester tester) async {
  await tester.pumpWidget(const ProviderScope(child: MainApp()));
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

/// Deja la app en [location] sin reconstruirla. Los archivos de prueba corren
/// en secuencia sobre el mismo router, así que cada uno declara desde dónde
/// arranca en vez de asumir dónde lo dejó el anterior.
Future<void> goTo(WidgetTester tester, String location) async {
  appRouter.go(location);
  await settle(tester);
}

/// Cierra la sesión si hay una abierta, para que el flujo de autenticación
/// empiece siempre desde el mismo estado.
Future<void> clearSession() async {
  if (Supabase.instance.client.auth.currentSession != null) {
    await Supabase.instance.client.auth.signOut();
  }
}

bool get hasSession => Supabase.instance.client.auth.currentSession != null;
