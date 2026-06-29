import 'package:eventix/core/router/go_router_refresh_stream.dart';
import 'package:eventix/core/router/routes.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Rutas que requieren sesión activa.
const Set<String> _privateRoutes = <String>{
  HomePage.routePath,
  OnboardingPage.routePath,
};

final GoRouter appRouter = GoRouter(
  initialLocation: SplashPage.routePath,
  refreshListenable: GoRouterRefreshStream(
    Supabase.instance.client.auth.onAuthStateChange,
  ),
  redirect: (BuildContext context, GoRouterState state) {
    final bool loggedIn =
        Supabase.instance.client.auth.currentSession != null;
    final String loc = state.matchedLocation;

    // Sin sesión no se puede entrar a rutas privadas.
    if (!loggedIn && _privateRoutes.contains(loc)) {
      return LoginPage.routePath;
    }
    // Con sesión, no tiene sentido ver login/registro.
    if (loggedIn &&
        (loc == LoginPage.routePath || loc == RegisterPage.routePath)) {
      return HomePage.routePath;
    }
    return null;
  },
  routes: <RouteBase>[splashRoute, homeRoute, ...authRoutes],
);
