import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/auth/di/auth_di.dart';
import 'package:eventix/features/auth/domain/usecases/update_password_use_case.dart';
import 'package:eventix/features/auth/presentation/providers/new_password_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockUpdatePassword extends Mock implements UpdatePasswordUseCase {}

void main() {
  late _MockUpdatePassword updatePassword;
  late ProviderContainer container;

  setUp(() {
    updatePassword = _MockUpdatePassword();
    container = ProviderContainer(
      overrides: <Override>[
        updatePasswordProvider.overrideWithValue(updatePassword),
      ],
    );
    addTearDown(container.dispose);
  });

  test('expone AsyncData al actualizar con Success', () async {
    when(
      () => updatePassword.call(newPassword: any(named: 'newPassword')),
    ).thenAnswer((_) async => const Success<void>(null));

    await container
        .read(newPasswordProvider.notifier)
        .updatePassword(newPassword: 'nueva123');

    expect(container.read(newPasswordProvider), isA<AsyncData<void>>());
  });

  test('expone AsyncError con el Failure cuando falla', () async {
    when(
      () => updatePassword.call(newPassword: any(named: 'newPassword')),
    ).thenAnswer(
      (_) async => const FailureResult<void>(
        ValidationFailure('La contraseña es muy corta.'),
      ),
    );

    await container
        .read(newPasswordProvider.notifier)
        .updatePassword(newPassword: '123');

    final AsyncValue<void> state = container.read(newPasswordProvider);
    expect(state, isA<AsyncError<void>>());
    expect((state as AsyncError<void>).error, isA<ValidationFailure>());
  });
}
