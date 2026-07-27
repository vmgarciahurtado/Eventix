import 'package:eventix/features/events/presentation/pages/event_detail_page.dart';
import 'package:eventix/features/events/presentation/pages/events_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final List<RouteBase> eventsRoutes = <RouteBase>[
  GoRoute(
    path: EventsPage.routePath,
    builder: (BuildContext context, GoRouterState state) => const EventsPage(),
  ),
  GoRoute(
    path: EventDetailPage.routePath,
    builder: (BuildContext context, GoRouterState state) =>
        EventDetailPage(eventId: state.pathParameters['id']!),
  ),
];
