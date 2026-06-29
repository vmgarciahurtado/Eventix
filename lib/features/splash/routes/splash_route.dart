import 'package:eventix/features/splash/presentation/pages/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GoRoute splashRoute = GoRoute(
  path: SplashPage.routePath,
  builder: (BuildContext context, GoRouterState state) => const SplashPage(),
);
