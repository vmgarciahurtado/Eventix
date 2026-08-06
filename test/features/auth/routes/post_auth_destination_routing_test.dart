import 'package:eventix/core/router/app_router.dart';
import 'package:eventix/features/auth/domain/enums/post_auth_destination.dart';
import 'package:eventix/features/auth/routes/post_auth_destination_routing.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// Recoge los paths de todo el árbol de rutas, incluidas las anidadas.
List<String> _paths(List<RouteBase> routes) => <String>[
  for (final RouteBase route in routes)
    if (route is GoRoute) ...<String>[route.path, ..._paths(route.routes)],
];

void main() {
  test('cada destino apunta al path de su página', () {
    expect(PostAuthDestination.login.routePath, '/login');
    expect(PostAuthDestination.home.routePath, '/events');
    expect(PostAuthDestination.onboarding.routePath, '/onboarding');
  });

  test('todo destino resuelve a una ruta registrada en el router', () {
    // Un path fuera del router deja al usuario en una pantalla de error.
    final List<String> registered = _paths(appRouter.configuration.routes);

    for (final PostAuthDestination destination in PostAuthDestination.values) {
      expect(
        registered,
        contains(destination.routePath),
        reason: '$destination apunta a una ruta que no existe',
      );
    }
  });

  test('el router no declara paths duplicados', () {
    final List<String> registered = _paths(appRouter.configuration.routes);

    expect(registered.toSet(), hasLength(registered.length));
  });

  test('la ruta inicial del router existe', () {
    expect(_paths(appRouter.configuration.routes), contains('/'));
  });
}
