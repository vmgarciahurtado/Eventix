import 'dart:async';

import 'package:eventix/core/widgets/app_logo.dart';
import 'package:eventix/features/app_config/domain/entities/app_config.dart';
import 'package:eventix/features/app_config/domain/entities/brand_config.dart';
import 'package:eventix/features/app_config/presentation/providers/app_config_provider.dart';
import 'package:eventix/features/auth/di/auth_di.dart';
import 'package:eventix/features/auth/domain/enums/post_auth_destination.dart';
import 'package:eventix/features/auth/domain/usecases/resolve_post_auth_destination.dart';
import 'package:eventix/features/auth/presentation/pages/login_page.dart';
import 'package:eventix/features/events/presentation/pages/events_page.dart';
import 'package:eventix/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:eventix/features/splash/presentation/pages/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/pump_app.dart';

class _MockResolvePostAuthDestination extends Mock
    implements ResolvePostAuthDestination {}

void main() {
  late _MockResolvePostAuthDestination resolveDestination;

  setUp(() => resolveDestination = _MockResolvePostAuthDestination());

  Future<void> pumpSplash(WidgetTester tester, {AppConfig? config}) =>
      pumpRoutes(
    tester,
    initialLocation: SplashPage.routePath,
    overrides: <Override>[
      resolvePostAuthDestinationProvider.overrideWithValue(resolveDestination),
      if (config != null) appConfigOverride(config),
    ],
    routes: <RouteBase>[
      GoRoute(
        path: SplashPage.routePath,
        builder: (BuildContext context, GoRouterState state) =>
            const SplashPage(),
      ),
      stubRoute(LoginPage.routePath, 'LOGIN'),
      stubRoute(EventsPage.routePath, 'CATALOGO'),
      stubRoute(OnboardingPage.routePath, 'ONBOARDING'),
    ],
  );

  testWidgets('muestra el lockup y el eslogan de la marca', (
    WidgetTester tester,
  ) async {
    when(
      resolveDestination.call,
    ).thenAnswer((_) async => PostAuthDestination.login);

    await pumpSplash(tester);

    expect(find.byType(AppLogo), findsOneWidget);
    expect(find.text('TU PRÓXIMA FIESTA EMPIEZA AQUÍ'), findsOneWidget);

    await tester.pumpAndSettle();
  });

  testWidgets('sin sesión lleva al login', (WidgetTester tester) async {
    when(
      resolveDestination.call,
    ).thenAnswer((_) async => PostAuthDestination.login);

    await pumpSplash(tester);
    await tester.pumpAndSettle();

    expect(find.text('LOGIN'), findsOneWidget);
  });

  testWidgets('con sesión y onboarding pendiente lleva al onboarding', (
    WidgetTester tester,
  ) async {
    when(
      resolveDestination.call,
    ).thenAnswer((_) async => PostAuthDestination.onboarding);

    await pumpSplash(tester);
    await tester.pumpAndSettle();

    expect(find.text('ONBOARDING'), findsOneWidget);
  });

  testWidgets('si resolver la sesión explota, entra al catálogo', (
    WidgetTester tester,
  ) async {
    when(resolveDestination.call).thenThrow(Exception('sin red'));

    await pumpSplash(tester);
    await tester.pumpAndSettle();

    // Quedarse atrapado en el splash sería la peor salida posible.
    expect(find.text('CATALOGO'), findsOneWidget);
  });

  testWidgets('si resolver la sesión se cuelga, no deja atrapado al usuario', (
    WidgetTester tester,
  ) async {
    // Nunca responde: es el caso de un backend que no cierra la conexión.
    when(resolveDestination.call).thenAnswer(
      (_) => Completer<PostAuthDestination>().future,
    );

    await pumpSplash(tester);
    // El timeout del splash es de 5 s.
    await tester.pump(const Duration(seconds: 7));
    await tester.pumpAndSettle();

    expect(find.text('CATALOGO'), findsOneWidget);
  });
  testWidgets('el eslogan sale del JSON, no del ARB', (
    WidgetTester tester,
  ) async {
    when(
      resolveDestination.call,
    ).thenAnswer((_) async => PostAuthDestination.login);

    await pumpSplash(
      tester,
      config: tAppConfig(
        brand: BrandConfig(
          tagline: tText('Otra promesa'),
          primaryArgb: BrandConfig.fallback.primaryArgb,
          secondaryArgb: BrandConfig.fallback.secondaryArgb,
        ),
      ),
    );

    expect(find.text('OTRA PROMESA'), findsOneWidget);
    expect(find.text('TU PRÓXIMA FIESTA EMPIEZA AQUÍ'), findsNothing);

    await tester.pumpAndSettle();
  });

}
