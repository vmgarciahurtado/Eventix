import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/core/env/env.dart';
import 'package:eventix/core/router/app_router.dart';
import 'package:eventix/core/widgets/app_loading_view.dart';
import 'package:eventix/main.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'test_credentials.dart';

bool _initialized = false;

/// Replica el arranque de `main()` `main_test.dart`
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

/// Bombea hasta que la UI deje de animar. Para esperar datos, [pumpUntil].
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

/// Bombea hasta que [condition] se cumpla, o falla diciendo qué se esperaba.
Future<void> pumpUntil(
  WidgetTester tester,
  bool Function() condition, {
  required String reason,
  Duration timeout = const Duration(seconds: 30),
}) async {
  final DateTime deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    if (condition()) {
      // Una pasada más para que se asiente lo que la condición destrabó.
      await settle(tester, timeout: const Duration(seconds: 3));
      return;
    }
    await tester.pump(const Duration(milliseconds: 100));
  }
  throw StateError('Se agotó el tiempo esperando: $reason');
}

/// Espera a que la pantalla termine de cargar sus datos.
Future<void> waitForData(WidgetTester tester) => pumpUntil(
  tester,
  () =>
      find.byType(AppLoadingView).evaluate().isEmpty &&
      find.byType(UiLoader).evaluate().isEmpty &&
      find.text('Consultando disponibilidad…').evaluate().isEmpty,
  reason: 'que la pantalla termine de cargar sus datos',
);

/// Monta la app y la deja en [location].
Future<void> launchAt(WidgetTester tester, String location) async {
  await tester.pumpWidget(const ProviderScope(child: MainApp()));
  appRouter.go(location);
  await settle(tester);
}

/// Cierra la sesión si hay una abierta.
Future<void> clearSession() async {
  if (hasSession) await Supabase.instance.client.auth.signOut();
}

/// Abre sesión por API, sin pasar por la pantalla.
Future<void> ensureSignedIn() async {
  if (hasSession) return;
  await Supabase.instance.client.auth.signInWithPassword(
    email: TestCredentials.email,
    password: TestCredentials.password,
  );
}

bool get hasSession => Supabase.instance.client.auth.currentSession != null;
