import 'package:eventix/core/router/routes.dart';
import 'package:go_router/go_router.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: SplashPage.routePath,
  routes: <RouteBase>[
    splashRoute,
    ...authRoutes,
    ...eventsRoutes,
    ...reservationsRoutes,
  ],
);
