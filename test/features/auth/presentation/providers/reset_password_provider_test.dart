import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/auth/di/auth_di.dart';
import 'package:eventix/features/auth/domain/usecases/send_password_reset_use_case.dart';
import 'package:eventix/features/auth/presentation/providers/reset_password_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockSendPasswordReset extends Mock implements SendPasswordResetUseCase {}

void main() {
  late _MockSendPasswordReset sendPasswordReset;
  late ProviderContainer container;

  setUp(() {
    sendPasswordReset = _MockSendPasswordReset();
    container = ProviderContainer(
      overrides: <Override>[
        sendPasswordResetProvider.overrideWithValue(sendPasswordReset),
      ],
    );
    addTearDown(container.dispose);
  });

  void mockSend(Result<void> result) {
    when(
      () => sendPasswordReset.call(email: any(named: 'email')),
    ).thenAnswer((_) async => result);
  }

  Future<void> sendResetCode() {
    return container
        .read(resetPasswordProvider.notifier)
        .sendResetCode(email: 'a@b.com');
  }

  test('expone el email al que se envió el código cuando funciona', () async {
    mockSend(const Success<void>(null));

    await sendResetCode();

    final AsyncValue<String?> state = container.read(resetPasswordProvider);
    expect(state, isA<AsyncData<String?>>());
    expect((state as AsyncData<String?>).value, 'a@b.com');
  });

  test('expone AsyncError con el Failure cuando falla', () async {
    mockSend(const FailureResult<void>(ConnectionFailure()));

    await sendResetCode();

    final AsyncValue<String?> state = container.read(resetPasswordProvider);
    expect(state, isA<AsyncError<String?>>());
    expect((state as AsyncError<String?>).error, isA<ConnectionFailure>());
  });
}
