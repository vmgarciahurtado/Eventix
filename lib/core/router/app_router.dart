import 'package:eventix/core/router/go_router_refresh_stream.dart';
import 'package:eventix/core/router/routes.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: SplashPage.routePath,
  refreshListenable: GoRouterRefreshStream(
    Supabase.instance.client.auth.onAuthStateChange,
  ),
  redirect: (BuildContext context, GoRouterState state) {
    final bool loggedIn =
        Supabase.instance.client.auth.currentSession != null;
    final String loc = state.matchedLocation;

    // El splash siempre es accesible: decide la ruta inicial.
    final bool isPublic =
        loc == SplashPage.routePath || publicAuthRoutes.contains(loc);

    // Sin sesión solo se permiten rutas públicas.
    if (!loggedIn && !isPublic) return LoginPage.routePath;

    // Con sesión, login/registro no tienen sentido.
    if (loggedIn &&
        (loc == LoginPage.routePath || loc == RegisterPage.routePath)) {
      return HomePage.routePath;
    }
    return null;
  },
  routes: <RouteBase>[
    splashRoute,
    homeRoute,
    ...authRoutes,
    ...eventsRoutes,
  ],
);
