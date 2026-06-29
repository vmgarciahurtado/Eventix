import 'package:eventix/features/home/presentation/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GoRoute homeRoute = GoRoute(
  path: HomePage.routePath,
  builder: (BuildContext context, GoRouterState state) => const HomePage(),
);
