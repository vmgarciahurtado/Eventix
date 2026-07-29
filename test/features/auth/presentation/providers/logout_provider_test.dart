import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/auth/di/auth_di.dart';
import 'package:eventix/features/auth/domain/usecases/sign_out.dart';
import 'package:eventix/features/auth/presentation/providers/logout_provider.dart';
import 'package:eventix/features/reservations/di/reservations_di.dart';
import 'package:eventix/features/reservations/domain/entities/reservation.dart';
import 'package:eventix/features/reservations/domain/enums/reservation_status.dart';
import 'package:eventix/features/reservations/domain/usecases/get_my_reservations.dart';
import 'package:eventix/features/reservations/presentation/providers/my_reservations_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockSignOut extends Mock implements SignOut {}

class _MockGetMyReservations extends Mock implements GetMyReservations {}

void main() {
  late _MockSignOut signOut;
  late _MockGetMyReservations getMyReservations;
  late ProviderContainer container;

  setUp(() {
    signOut = _MockSignOut();
    getMyReservations = _MockGetMyReservations();
    container = ProviderContainer(
      overrides: <Override>[
        signOutProvider.overrideWithValue(signOut),
        getMyReservationsProvider.overrideWithValue(getMyReservations),
      ],
    );
    addTearDown(container.dispose);
  });

  void mockSignOut(Result<void> result) =>
      when(signOut.call).thenAnswer((_) async => result);

  Future<void> logout() => container.read(logoutProvider.notifier).logout();

  test('expone AsyncData al cerrar sesión con Success', () async {
    mockSignOut(const Success<void>(null));

    await logout();

    expect(container.read(logoutProvider), isA<AsyncData<void>>());
  });

  test('expone AsyncError con el Failure cuando falla', () async {
    mockSignOut(const FailureResult<void>(ConnectionFailure()));

    await logout();

    final AsyncValue<void> state = container.read(logoutProvider);
    expect(state, isA<AsyncError<void>>());
    expect((state as AsyncError<void>).error, isA<ConnectionFailure>());
  });

  test('ignora un segundo toque mientras el primero está en curso', () async {
    mockSignOut(const Success<void>(null));

    await Future.wait<void>(<Future<void>>[logout(), logout()]);

    verify(signOut.call).called(1);
  });

  test('descarta las reservas cacheadas del usuario que se va', () async {
    mockSignOut(const Success<void>(null));
    when(getMyReservations.call).thenAnswer(
      (_) async => Success<List<Reservation>>(<Reservation>[
        Reservation(
          id: 'res-de-A',
          eventTitle: 'Festival',
          quantity: 1,
          status: ReservationStatus.confirmed,
          createdAt: DateTime.utc(2026, 6, 29),
          eventStartsAt: DateTime.utc(2026, 7, 4, 20),
        ),
      ]),
    );
    // Suscripción viva: simula la pantalla de reservas todavía montada, que es
    // el único caso donde el autoDispose no basta por sí solo.
    container.listen(
      myReservationsProvider,
      (AsyncValue<List<Reservation>>? _, AsyncValue<List<Reservation>> __) {},
    );
    await container.read(myReservationsProvider.future);

    await logout();
    await container.read(myReservationsProvider.future);

    // Dos llamadas: la del usuario A y la que provoca el logout al invalidar.
    verify(getMyReservations.call).called(2);
  });

  test('no descarta nada si el cierre de sesión falla', () async {
    mockSignOut(const FailureResult<void>(ConnectionFailure()));
    when(
      getMyReservations.call,
    ).thenAnswer(
      (_) async => const Success<List<Reservation>>(<Reservation>[]),
    );
    container.listen(
      myReservationsProvider,
      (AsyncValue<List<Reservation>>? _, AsyncValue<List<Reservation>> __) {},
    );
    await container.read(myReservationsProvider.future);

    await logout();
    await container.read(myReservationsProvider.future);

    verify(getMyReservations.call).called(1);
  });
}
