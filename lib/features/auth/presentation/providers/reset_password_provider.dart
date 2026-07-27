import 'dart:async';

import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/auth/di/auth_di.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Envío del código de recuperación. El estado es el correo al que se envió.
class ResetPasswordNotifier extends AsyncNotifier<String?> {
  @override
  FutureOr<String?> build() => null;

  Future<void> sendResetCode({required String email}) async {
    if (state.isLoading) return;
    state = const AsyncLoading<String?>();

    final Result<void> result = await ref
        .read(sendPasswordResetProvider)
        .call(email: email);
    if (!ref.mounted) return;

    state = switch (result) {
      Success<void>() => AsyncData<String?>(email),
      FailureResult<void>(:final Failure failure) => AsyncError<String?>(
        failure,
        StackTrace.current,
      ),
    };
  }
}

final AsyncNotifierProvider<ResetPasswordNotifier, String?>
resetPasswordProvider = AsyncNotifierProvider<ResetPasswordNotifier, String?>(
  ResetPasswordNotifier.new,
);
