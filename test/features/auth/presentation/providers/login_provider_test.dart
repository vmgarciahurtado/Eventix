import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/auth/di/auth_di.dart';
import 'package:eventix/features/auth/domain/enums/post_auth_destination.dart';
import 'package:eventix/features/auth/domain/usecases/resolve_post_auth_destination_use_case.dart';
import 'package:eventix/features/auth/domain/usecases/sign_in_use_case.dart';
import 'package:eventix/features/auth/presentation/providers/login_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockSignIn extends Mock implements SignInUseCase {}

class _MockResolvePostAuthDestination extends Mock
    implements ResolvePostAuthDestinationUseCase {}

void main() {
  late _MockSignIn signIn;
  late _MockResolvePostAuthDestination resolveDestination;
  late ProviderContainer container;

  setUp(() {
    signIn = _MockSignIn();
    resolveDestination = _MockResolvePostAuthDestination();
    container = ProviderContainer(
      overrides: <Override>[
        signInProvider.overrideWithValue(signIn),
        resolvePostAuthDestinationProvider.overrideWithValue(
          resolveDestination,
        ),
      ],
    );
    addTearDown(container.dispose);
  });

  void mockSignIn(Result<void> result) {
    when(
      () => signIn.call(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => result);
  }

  Future<void> doSignIn() {
    return container
        .read(loginProvider.notifier)
        .signIn(email: 'a@b.com', password: '123456');
  }

  test('arranca inactivo, no cargando', () {
    // `build` es síncrono a propósito: si devolviera un Future, el estado
    // inicial sería AsyncLoading y el botón aparecería cargando al abrir.
    final AsyncValue<PostAuthDestination?> state = container.read(
      loginProvider,
    );
    expect(state.isLoading, isFalse);
    expect(state, isA<AsyncData<PostAuthDestination?>>());
    expect((state as AsyncData<PostAuthDestination?>).value, isNull);
  });

  test('expone el destino resuelto cuando la autenticación funciona', () async {
    mockSignIn(const Success<void>(null));
    when(
      resolveDestination.call,
    ).thenAnswer((_) async => PostAuthDestination.onboarding);

    await doSignIn();

    final AsyncValue<PostAuthDestination?> state = container.read(
      loginProvider,
    );
    expect(state, isA<AsyncData<PostAuthDestination?>>());
    expect(
      (state as AsyncData<PostAuthDestination?>).value,
      PostAuthDestination.onboarding,
    );
  });

  test(
    'expone AsyncError con el Failure cuando falla la autenticación',
    () async {
      mockSignIn(const FailureResult<void>(AuthFailure('Credenciales.')));

      await doSignIn();

      final AsyncValue<PostAuthDestination?> state = container.read(
        loginProvider,
      );
      expect(state, isA<AsyncError<PostAuthDestination?>>());
      expect(
        (state as AsyncError<PostAuthDestination?>).error,
        isA<AuthFailure>(),
      );
    },
  );

  test('no resuelve el destino si la autenticación falla', () async {
    mockSignIn(const FailureResult<void>(AuthFailure('Credenciales.')));

    await doSignIn();

    verifyNever(resolveDestination.call);
  });
}
