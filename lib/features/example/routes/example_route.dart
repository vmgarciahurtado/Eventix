import 'package:flutter/material.dart';
import 'package:eventix/features/example/presentation/pages/examples_page.dart';
import 'package:go_router/go_router.dart';

final GoRoute exampleRoute = GoRoute(
  path: ExamplesPage.routePath,
  builder: (BuildContext context, GoRouterState state) =>
      const ExamplesPage(),
);
