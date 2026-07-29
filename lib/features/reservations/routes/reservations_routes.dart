import 'package:eventix/features/reservations/presentation/pages/my_reservations_page.dart';
import 'package:eventix/features/reservations/presentation/pages/reservation_confirmed_page.dart';
import 'package:eventix/features/reservations/presentation/pages/reserve_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final List<RouteBase> reservationsRoutes = <RouteBase>[
  GoRoute(
    path: MyReservationsPage.routePath,
    builder: (BuildContext context, GoRouterState state) =>
        const MyReservationsPage(),
  ),
  GoRoute(
    path: ReservationConfirmedPage.routePath,
    builder: (BuildContext context, GoRouterState state) =>
        const ReservationConfirmedPage(),
  ),
  GoRoute(
    path: ReservePage.routePath,
    builder: (BuildContext context, GoRouterState state) =>
        ReservePage(eventId: state.pathParameters['id']!),
  ),
];
