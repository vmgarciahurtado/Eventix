import 'package:eventix/core/l10n/app_localizations.dart';
import 'package:eventix/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Monta widgets con el entorno de `main.dart`: tema, locale y `ProviderScope`.

Future<void> initSpanishDates() => initializeDateFormatting('es');

Widget _app({
  required Widget home,
  List<Override> overrides = const <Override>[],
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      locale: const Locale('es'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.dark,
      home: home,
    ),
  );
}

/// Para páginas: ya traen su propio `Scaffold`.
Future<void> pumpPage(
  WidgetTester tester,
  Widget page, {
  List<Override> overrides = const <Override>[],
}) => tester.pumpWidget(_app(home: page, overrides: overrides));

/// Para componentes sueltos, que necesitan un `Scaffold` alrededor.
Future<void> pumpComponent(
  WidgetTester tester,
  Widget component, {
  List<Override> overrides = const <Override>[],
}) => tester.pumpWidget(
  _app(
    home: Scaffold(body: component),
    overrides: overrides,
  ),
);

/// Para lo que navega: necesita un `GoRouter` real. [initialExtra] llega al
/// builder como `state.extra`.
Future<void> pumpRoutes(
  WidgetTester tester, {
  required List<RouteBase> routes,
  required String initialLocation,
  List<Override> overrides = const <Override>[],
  Object? initialExtra,
}) => tester.pumpWidget(
  ProviderScope(
    overrides: overrides,
    child: MaterialApp.router(
      locale: const Locale('es'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.dark,
      routerConfig: GoRouter(
        initialLocation: initialLocation,
        initialExtra: initialExtra,
        routes: routes,
      ),
    ),
  ),
);

/// Ruta de destino que solo declara dónde quedó la navegación.
GoRoute stubRoute(String path, String marker) => GoRoute(
  path: path,
  builder: (BuildContext context, GoRouterState state) =>
      Scaffold(body: Text(marker)),
);
