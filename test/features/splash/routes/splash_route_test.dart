import 'package:eventix/features/auth/di/auth_di.dart';
import 'package:eventix/features/auth/domain/enums/post_auth_destination.dart';
import 'package:eventix/features/auth/domain/usecases/resolve_post_auth_destination.dart';
import 'package:eventix/features/auth/presentation/pages/login_page.dart';
import 'package:eventix/features/splash/presentation/pages/splash_page.dart';
import 'package:eventix/features/splash/routes/splash_route.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/pump_app.dart';

class _MockResolvePostAuthDestination extends Mock
    implements ResolvePostAuthDestination {}

void main() {
  late _MockResolvePostAuthDestination resolveDestination;

  setUp(() {
    resolveDestination = _MockResolvePostAuthDestination();
    when(
      resolveDestination.call,
    ).thenAnswer((_) async => PostAuthDestination.login);
  });

  testWidgets('la ruta real del splash monta el splash', (
    WidgetTester tester,
  ) async {
    await pumpRoutes(
      tester,
      initialLocation: SplashPage.routePath,
      overrides: <Override>[
        resolvePostAuthDestinationProvider.overrideWithValue(
          resolveDestination,
        ),
      ],
      routes: <RouteBase>[
        splashRoute,
        stubRoute(LoginPage.routePath, 'LOGIN'),
      ],
    );

    expect(find.byType(SplashPage), findsOneWidget);

    await tester.pumpAndSettle();
  });

  test('el splash está en la raíz', () {
    expect(splashRoute.path, '/');
  });
}
