import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/app_config/domain/entities/banner_config.dart';
import 'package:eventix/features/app_config/domain/entities/home_config.dart';
import 'package:eventix/features/app_config/domain/enums/app_icon.dart';
import 'package:eventix/features/app_config/domain/enums/banner_target.dart';
import 'package:eventix/features/app_config/domain/enums/home_block.dart';
import 'package:eventix/features/app_config/presentation/providers/app_config_provider.dart';
import 'package:eventix/features/auth/di/auth_di.dart';
import 'package:eventix/features/auth/domain/usecases/sign_out.dart';
import 'package:eventix/features/auth/presentation/pages/login_page.dart';
import 'package:eventix/features/events/di/events_di.dart';
import 'package:eventix/features/events/domain/entities/category.dart';
import 'package:eventix/features/events/domain/entities/city.dart';
import 'package:eventix/features/events/domain/entities/event.dart';
import 'package:eventix/features/events/domain/entities/event_filter.dart';
import 'package:eventix/features/events/domain/usecases/get_categories.dart';
import 'package:eventix/features/events/domain/usecases/get_cities.dart';
import 'package:eventix/features/events/domain/usecases/get_events.dart';
import 'package:eventix/features/events/presentation/pages/event_detail_page.dart';
import 'package:eventix/features/events/presentation/pages/events_page.dart';
import 'package:eventix/features/events/presentation/widgets/home_banner.dart';
import 'package:eventix/features/reservations/presentation/pages/my_reservations_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/pump_app.dart';

class _MockGetEvents extends Mock implements GetEvents {}

class _MockGetCategories extends Mock implements GetCategories {}

class _MockGetCities extends Mock implements GetCities {}

class _MockSignOut extends Mock implements SignOut {}

/// El banner navega, así que se monta dentro del catálogo con rutas reales.
void main() {
  late _MockGetEvents getEvents;

  setUpAll(() async {
    registerFallbackValue(const EventFilter());
    await initSpanishDates();
  });

  setUp(() {
    getEvents = _MockGetEvents();
    when(() => getEvents.call(any())).thenAnswer(
      (_) async => Success<List<Event>>(<Event>[tEvent()]),
    );
  });

  BannerConfig banner({
    bool enabled = true,
    AppIcon icon = AppIcon.party,
    BannerActionConfig? action,
  }) => BannerConfig(
    enabled: enabled,
    icon: icon,
    title: tText('La noche es tuya'),
    subtitle: tText('Cupos limitados'),
    action: action,
  );

  Future<void> pumpBanner(WidgetTester tester, BannerConfig config) async {
    final _MockGetCategories getCategories = _MockGetCategories();
    final _MockGetCities getCities = _MockGetCities();
    when(getCategories.call).thenAnswer(
      (_) async => const Success<List<Category>>(tCategories),
    );
    when(getCities.call).thenAnswer(
      (_) async => const Success<List<City>>(tCities),
    );

    await pumpRoutes(
      tester,
      initialLocation: EventsPage.routePath,
      overrides: <Override>[
        getEventsProvider.overrideWithValue(getEvents),
        getCategoriesProvider.overrideWithValue(getCategories),
        getCitiesProvider.overrideWithValue(getCities),
        signOutProvider.overrideWithValue(_MockSignOut()),
        appConfigOverride(
          tAppConfig(
            home: HomeConfig(
              blocks: HomeBlock.fallback,
              banner: config,
              emptyState: EmptyStateConfig.fallback,
            ),
          ),
        ),
      ],
      routes: <RouteBase>[
        GoRoute(
          path: EventsPage.routePath,
          builder: (BuildContext context, GoRouterState state) =>
              const EventsPage(),
        ),
        stubRoute(EventDetailPage.routePath, 'DETALLE'),
        stubRoute(MyReservationsPage.routePath, 'RESERVAS'),
        stubRoute(LoginPage.routePath, 'LOGIN'),
      ],
    );
    await tester.pumpAndSettle();
  }

  testWidgets('apagado no ocupa espacio', (WidgetTester tester) async {
    await pumpBanner(tester, banner(enabled: false));

    expect(find.text('LA NOCHE ES TUYA'), findsNothing);
    expect(tester.getSize(find.byType(HomeBanner)), Size.zero);
  });

  testWidgets('encendido muestra título, subtítulo e icono', (
    WidgetTester tester,
  ) async {
    await pumpBanner(tester, banner(icon: AppIcon.music));

    expect(find.text('LA NOCHE ES TUYA'), findsOneWidget);
    expect(find.text('Cupos limitados'), findsOneWidget);
    expect(find.byIcon(Icons.music_note_outlined), findsOneWidget);
  });

  testWidgets('sin acción no pinta botón', (WidgetTester tester) async {
    await pumpBanner(tester, banner());

    expect(find.descendant(
      of: find.byType(HomeBanner),
      matching: find.byType(TextButton),
    ), findsNothing);
  });

  testWidgets('el botón lleva al destino del archivo', (
    WidgetTester tester,
  ) async {
    await pumpBanner(
      tester,
      banner(
        action: BannerActionConfig(
          label: tText('Ver mis reservas'),
          target: BannerTarget.reservations,
        ),
      ),
    );

    await tester.tap(find.widgetWithText(TextButton, 'Ver mis reservas'));
    await tester.pumpAndSettle();

    expect(find.text('RESERVAS'), findsOneWidget);
  });

  testWidgets('con destino al catálogo se queda en el catálogo', (
    WidgetTester tester,
  ) async {
    await pumpBanner(
      tester,
      banner(
        action: BannerActionConfig(
          label: tText('Ver eventos'),
          target: BannerTarget.events,
        ),
      ),
    );

    await tester.tap(find.widgetWithText(TextButton, 'Ver eventos'));
    await tester.pumpAndSettle();

    expect(find.byType(EventsPage), findsOneWidget);
  });

  test('el destino vacío no resuelve a ninguna ruta', () {
    expect(bannerTargetPath(BannerTarget.none), isNull);
    expect(bannerTargetPath(BannerTarget.events), EventsPage.routePath);
    expect(
      bannerTargetPath(BannerTarget.reservations),
      MyReservationsPage.routePath,
    );
  });

  test('una acción sin etiqueta no se considera usable', () {
    // Pintaría un botón vacío que no lleva a ninguna parte.
    expect(
      BannerActionConfig(
        label: tText('   '),
        target: BannerTarget.events,
      ).isUsable,
      isFalse,
    );
    expect(
      BannerActionConfig(
        label: tText('Ir'),
        target: BannerTarget.none,
      ).isUsable,
      isFalse,
    );
  });
}
