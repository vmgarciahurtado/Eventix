import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/auth/di/auth_di.dart';
import 'package:eventix/features/auth/domain/usecases/sign_out.dart';
import 'package:eventix/features/auth/presentation/providers/logout_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockSignOut extends Mock implements SignOut {}

void main() {
  late _MockSignOut signOut;
  late ProviderContainer container;

  setUp(() {
    signOut = _MockSignOut();
    container = ProviderContainer(
      overrides: <Override>[signOutProvider.overrideWithValue(signOut)],
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
}
