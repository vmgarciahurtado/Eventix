import 'package:eventix/core/router/routes.dart';
import 'package:go_router/go_router.dart';

/// Router temporal de la Fase 0. En la Fase A se agrega el guard de sesión
/// (redirect basado en el estado de auth de Supabase) y las rutas de auth.
final GoRouter appRouter = GoRouter(
  initialLocation: SplashPage.routePath,
  routes: <RouteBase>[splashRoute, homeRoute],
);
