import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/app_config/domain/entities/app_config.dart';
import 'package:eventix/features/app_config/domain/entities/onboarding_config.dart';
import 'package:eventix/features/app_config/domain/enums/app_icon.dart';
import 'package:eventix/features/app_config/presentation/providers/app_config_provider.dart';
import 'package:eventix/features/events/presentation/pages/events_page.dart';
import 'package:eventix/features/onboarding/di/onboarding_di.dart';
import 'package:eventix/features/onboarding/domain/usecases/complete_onboarding.dart';
import 'package:eventix/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:eventix/features/onboarding/presentation/widgets/onboarding_slide.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/pump_app.dart';

class _MockCompleteOnboarding extends Mock implements CompleteOnboarding {}

void main() {
  late _MockCompleteOnboarding completeOnboarding;

  setUp(() => completeOnboarding = _MockCompleteOnboarding());

  Future<void> pumpOnboarding(WidgetTester tester, {AppConfig? config}) =>
      pumpRoutes(
    tester,
    initialLocation: OnboardingPage.routePath,
    overrides: <Override>[
      completeOnboardingProvider.overrideWithValue(completeOnboarding),
      if (config != null) appConfigOverride(config),
    ],
    routes: <RouteBase>[
      GoRoute(
        path: OnboardingPage.routePath,
        builder: (BuildContext context, GoRouterState state) =>
            const OnboardingPage(),
      ),
      stubRoute(EventsPage.routePath, 'CATALOGO'),
    ],
  );

  testWidgets('arranca en la primera diapositiva y ofrece avanzar', (
    WidgetTester tester,
  ) async {
    await pumpOnboarding(tester);

    expect(find.text('Descubre eventos'), findsOneWidget);
    expect(find.widgetWithText(UiButton, 'Siguiente'), findsOneWidget);
  });

  testWidgets('avanza por las tres diapositivas', (WidgetTester tester) async {
    await pumpOnboarding(tester);

    await tester.tap(find.widgetWithText(UiButton, 'Siguiente'));
    await tester.pumpAndSettle();
    expect(find.text('Filtra a tu medida'), findsOneWidget);

    await tester.tap(find.widgetWithText(UiButton, 'Siguiente'));
    await tester.pumpAndSettle();
    expect(find.text('Reserva tus cupos'), findsOneWidget);

    // En la última el botón cambia: ya no hay a dónde avanzar.
    expect(find.widgetWithText(UiButton, 'Comenzar'), findsOneWidget);
    expect(find.byType(OnboardingSlide), findsWidgets);
  });

  testWidgets('saltar guarda la preferencia y entra al catálogo', (
    WidgetTester tester,
  ) async {
    when(
      completeOnboarding.call,
    ).thenAnswer((_) async => const Success<void>(null));

    await pumpOnboarding(tester);
    await tester.tap(find.text('Saltar'));
    await tester.pumpAndSettle();

    verify(completeOnboarding.call).called(1);
    expect(find.text('CATALOGO'), findsOneWidget);
  });

  testWidgets('si el guardado falla igual entra, pero avisa', (
    WidgetTester tester,
  ) async {
    when(completeOnboarding.call).thenAnswer(
      (_) async => const FailureResult<void>(ServerFailure()),
    );

    await pumpOnboarding(tester);
    await tester.tap(find.text('Saltar'));
    await tester.pump();

    // Dejarlo atrapado en el onboarding por un fallo de guardado sería peor
    // que repetirle la introducción la próxima vez.
    expect(find.byType(SnackBar), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('CATALOGO'), findsOneWidget);
  });
  group('parametrización', () {
    testWidgets('el archivo decide cuántas láminas hay', (
      WidgetTester tester,
    ) async {
      await pumpOnboarding(
        tester,
        config: tAppConfig(
          onboarding: OnboardingConfig(
            slides: <OnboardingSlideConfig>[
              OnboardingSlideConfig(
                icon: AppIcon.music,
                title: tText('Solo una'),
                body: tText('Y ya está'),
              ),
            ],
          ),
        ),
      );

      // Con una sola lámina el botón ya es el de terminar.
      expect(find.byType(OnboardingSlide), findsOneWidget);
      expect(find.text('Solo una'), findsOneWidget);
      expect(find.widgetWithText(UiButton, 'Comenzar'), findsOneWidget);
    });

    testWidgets('agregar una lámina no toca la pantalla', (
      WidgetTester tester,
    ) async {
      await pumpOnboarding(
        tester,
        config: tAppConfig(
          onboarding: OnboardingConfig(
            slides: <OnboardingSlideConfig>[
              for (int i = 1; i <= 4; i++)
                OnboardingSlideConfig(
                  icon: AppIcon.star,
                  title: tText('Lámina $i'),
                  body: tText('Cuerpo $i'),
                ),
            ],
          ),
        ),
      );

      for (int i = 1; i <= 3; i++) {
        expect(find.text('Lámina $i'), findsOneWidget);
        await tester.tap(find.widgetWithText(UiButton, 'Siguiente'));
        await tester.pumpAndSettle();
      }

      expect(find.text('Lámina 4'), findsOneWidget);
      expect(find.widgetWithText(UiButton, 'Comenzar'), findsOneWidget);
    });

    testWidgets('el icono de la lámina sale del catálogo', (
      WidgetTester tester,
    ) async {
      await pumpOnboarding(
        tester,
        config: tAppConfig(
          onboarding: OnboardingConfig(
            slides: <OnboardingSlideConfig>[
              OnboardingSlideConfig(
                icon: AppIcon.music,
                title: tText('Suena'),
                body: tText('Duro'),
              ),
            ],
          ),
        ),
      );

      expect(find.byIcon(Icons.music_note_outlined), findsOneWidget);
    });
  });

}
