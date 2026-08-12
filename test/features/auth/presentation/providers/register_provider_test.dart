import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/auth/di/auth_di.dart';
import 'package:eventix/features/auth/domain/usecases/register_user_use_case.dart';
import 'package:eventix/features/auth/presentation/providers/register_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRegisterUser extends Mock implements RegisterUserUseCase {}

void main() {
  late _MockRegisterUser registerUser;
  late ProviderContainer container;

  setUp(() {
    registerUser = _MockRegisterUser();
    container = ProviderContainer(
      overrides: <Override>[
        registerUserProvider.overrideWithValue(registerUser),
      ],
    );
    addTearDown(container.dispose);
  });

  void mockRegister(Result<void> result) {
    when(
      () => registerUser.call(
        email: any(named: 'email'),
        password: any(named: 'password'),
        firstName: any(named: 'firstName'),
        lastName: any(named: 'lastName'),
      ),
    ).thenAnswer((_) async => result);
  }

  Future<void> register() {
    return container
        .read(registerProvider.notifier)
        .register(
          email: 'a@b.com',
          password: '123456',
          firstName: 'Ana',
          lastName: 'Gómez',
        );
  }

  test('arranca inactivo, sin email pendiente', () {
    final AsyncValue<String?> state = container.read(registerProvider);
    expect(state.isLoading, isFalse);
    expect((state as AsyncData<String?>).value, isNull);
  });

  test(
    'expone el email pendiente de verificar al completar con Success',
    () async {
      mockRegister(const Success<void>(null));

      await register();

      final AsyncValue<String?> state = container.read(registerProvider);
      expect(state, isA<AsyncData<String?>>());
      expect((state as AsyncData<String?>).value, 'a@b.com');
    },
  );

  test('expone AsyncError con el Failure cuando falla', () async {
    mockRegister(const FailureResult<void>(AuthFailure('Correo en uso.')));

    await register();

    final AsyncValue<String?> state = container.read(registerProvider);
    expect(state, isA<AsyncError<String?>>());
    expect((state as AsyncError<String?>).error, isA<AuthFailure>());
  });

  test('ignora un segundo submit mientras el primero está en curso', () async {
    mockRegister(const Success<void>(null));

    await Future.wait<void>(<Future<void>>[register(), register()]);

    verify(
      () => registerUser.call(
        email: any(named: 'email'),
        password: any(named: 'password'),
        firstName: any(named: 'firstName'),
        lastName: any(named: 'lastName'),
      ),
    ).called(1);
  });
}
