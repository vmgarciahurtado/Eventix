import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/core/widgets/app_empty_state.dart';
import 'package:eventix/core/widgets/app_loading_view.dart';
import 'package:eventix/core/widgets/async_error_view.dart';
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
import 'package:eventix/features/events/presentation/widgets/event_card.dart';
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

void main() {
  late _MockGetEvents getEvents;
  late _MockGetCategories getCategories;
  late _MockGetCities getCities;
  late _MockSignOut signOut;

  setUpAll(() async {
    registerFallbackValue(const EventFilter());
    await initSpanishDates();
  });

  setUp(() {
    getEvents = _MockGetEvents();
    getCategories = _MockGetCategories();
    getCities = _MockGetCities();
    signOut = _MockSignOut();
    when(getCategories.call).thenAnswer(
      (_) async => const Success<List<Category>>(tCategories),
    );
    when(getCities.call).thenAnswer(
      (_) async => const Success<List<City>>(tCities),
    );
  });

  List<Override> overrides() => <Override>[
    getEventsProvider.overrideWithValue(getEvents),
    getCategoriesProvider.overrideWithValue(getCategories),
    getCitiesProvider.overrideWithValue(getCities),
    signOutProvider.overrideWithValue(signOut),
  ];

  void mockEvents(Result<List<Event>> result) =>
      when(() => getEvents.call(any())).thenAnswer((_) async => result);

  /// El catálogo navega al detalle, a las reservas y al login: se montan como
  /// rutas de marca para verificar a dónde fue sin arrastrar esas pantallas.
  Future<void> pumpCatalog(WidgetTester tester) => pumpRoutes(
    tester,
    initialLocation: EventsPage.routePath,
    overrides: overrides(),
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

  testWidgets('mientras carga muestra el loader', (WidgetTester tester) async {
    mockEvents(const Success<List<Event>>(<Event>[]));

    await pumpCatalog(tester);

    expect(find.byType(AppLoadingView), findsOneWidget);
  });

  testWidgets('lista una tarjeta por evento', (WidgetTester tester) async {
    mockEvents(
      Success<List<Event>>(<Event>[
        tEvent(title: 'Fiesta uno'),
        tEvent(id: 'evt-2', title: 'Fiesta dos'),
      ]),
    );

    await pumpCatalog(tester);
    await tester.pumpAndSettle();

    expect(find.byType(EventCard), findsNWidgets(2));
    expect(find.text('Fiesta uno'), findsOneWidget);
    expect(find.text('Fiesta dos'), findsOneWidget);
  });

  testWidgets('sin eventos muestra el estado vacío', (
    WidgetTester tester,
  ) async {
    mockEvents(const Success<List<Event>>(<Event>[]));

    await pumpCatalog(tester);
    await tester.pumpAndSettle();

    expect(find.byType(AppEmptyState), findsOneWidget);
    expect(find.text('No encontramos eventos con estos filtros.'),
        findsOneWidget);
  });

  testWidgets('un fallo muestra el error con su mensaje', (
    WidgetTester tester,
  ) async {
    mockEvents(
      const FailureResult<List<Event>>(
        UnexpectedFailure('detalle interno'),
      ),
    );

    await pumpCatalog(tester);
    await tester.pumpAndSettle();

    expect(find.byType(AsyncErrorView), findsOneWidget);
    expect(find.text('Algo salió mal. Intenta de nuevo.'), findsOneWidget);
    expect(find.textContaining('detalle interno'), findsNothing);
  });

  testWidgets('tocar una tarjeta navega al detalle de ESE evento', (
    WidgetTester tester,
  ) async {
    mockEvents(Success<List<Event>>(<Event>[tEvent(id: 'evt-42')]));

    await pumpCatalog(tester);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(EventCard));
    await tester.pumpAndSettle();

    expect(find.text('DETALLE'), findsOneWidget);
  });

  testWidgets('el ícono de tiquetes abre mis reservas', (
    WidgetTester tester,
  ) async {
    mockEvents(const Success<List<Event>>(<Event>[]));

    await pumpCatalog(tester);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.confirmation_num_outlined));
    await tester.pumpAndSettle();

    expect(find.text('RESERVAS'), findsOneWidget);
  });

  testWidgets('actualizar vuelve a consultar el catálogo', (
    WidgetTester tester,
  ) async {
    mockEvents(const Success<List<Event>>(<Event>[]));

    await pumpCatalog(tester);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pumpAndSettle();

    verify(() => getEvents.call(any())).called(2);
  });

  testWidgets('cerrar sesión lleva al login', (WidgetTester tester) async {
    mockEvents(const Success<List<Event>>(<Event>[]));
    when(signOut.call).thenAnswer((_) async => const Success<void>(null));

    await pumpCatalog(tester);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.logout));
    await tester.pumpAndSettle();

    expect(find.text('LOGIN'), findsOneWidget);
  });

  testWidgets('si cerrar sesión falla se queda en el catálogo y avisa', (
    WidgetTester tester,
  ) async {
    mockEvents(const Success<List<Event>>(<Event>[]));
    when(signOut.call).thenAnswer(
      (_) async => const FailureResult<void>(ConnectionFailure()),
    );

    await pumpCatalog(tester);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.logout));
    await tester.pump();

    // Dejarlo en el login con la sesión viva sería mentirle sobre su estado.
    expect(find.text('LOGIN'), findsNothing);
    expect(
      find.widgetWithText(SnackBar, 'Sin conexión a internet'),
      findsOneWidget,
    );
  });

  testWidgets('los chips de categoría vienen del catálogo remoto', (
    WidgetTester tester,
  ) async {
    mockEvents(const Success<List<Event>>(<Event>[]));

    await pumpCatalog(tester);
    await tester.pumpAndSettle();

    expect(find.widgetWithText(FilterChip, 'Todas'), findsOneWidget);
    expect(find.widgetWithText(FilterChip, 'Reggaetón'), findsOneWidget);
    expect(find.widgetWithText(FilterChip, 'Electrónica'), findsOneWidget);
  });

  testWidgets('elegir una categoría vuelve a consultar con ese filtro', (
    WidgetTester tester,
  ) async {
    mockEvents(const Success<List<Event>>(<Event>[]));

    await pumpCatalog(tester);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilterChip, 'Reggaetón'));
    await tester.pumpAndSettle();

    final EventFilter used =
        verify(() => getEvents.call(captureAny())).captured.last as EventFilter;
    expect(used.categoryId, 1);
  });

  testWidgets('sin filtros activos no ofrece limpiarlos', (
    WidgetTester tester,
  ) async {
    mockEvents(const Success<List<Event>>(<Event>[]));

    await pumpCatalog(tester);
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.filter_alt_off_outlined), findsNothing);
  });

  testWidgets('con un filtro activo aparece el botón de limpiar', (
    WidgetTester tester,
  ) async {
    mockEvents(const Success<List<Event>>(<Event>[]));

    await pumpCatalog(tester);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilterChip, 'Reggaetón'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.filter_alt_off_outlined), findsOneWidget);

    await tester.tap(find.byIcon(Icons.filter_alt_off_outlined));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.filter_alt_off_outlined), findsNothing);
  });

  testWidgets('el selector de ciudad lista las ciudades del backend', (
    WidgetTester tester,
  ) async {
    mockEvents(const Success<List<Event>>(<Event>[]));

    await pumpCatalog(tester);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(OutlinedButton, 'Ciudad'));
    await tester.pumpAndSettle();

    expect(find.text('Todas las ciudades'), findsOneWidget);
    expect(find.widgetWithText(ListTile, 'Medellín'), findsOneWidget);

    await tester.tap(find.widgetWithText(ListTile, 'Medellín'));
    await tester.pumpAndSettle();

    final EventFilter used =
        verify(() => getEvents.call(captureAny())).captured.last as EventFilter;
    expect(used.cityId, 2);
  });

  testWidgets('reintentar tras un error vuelve a consultar', (
    WidgetTester tester,
  ) async {
    mockEvents(const FailureResult<List<Event>>(ServerFailure()));

    await pumpCatalog(tester);
    await tester.pumpAndSettle();

    mockEvents(Success<List<Event>>(<Event>[tEvent()]));
    await tester.tap(find.widgetWithText(UiButton, 'Reintentar'));
    await tester.pumpAndSettle();

    expect(find.byType(EventCard), findsOneWidget);
  });
}
