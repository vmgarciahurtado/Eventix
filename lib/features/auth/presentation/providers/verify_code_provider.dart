import 'dart:async';

import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/auth/di/auth_di.dart';
import 'package:eventix/features/auth/domain/enums/otp_purpose.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VerifyCodeNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> verify({
    required String email,
    required String token,
    required OtpPurpose purpose,
  }) async {
    if (state.isLoading) return;
    state = const AsyncLoading<void>();

    final Result<void> result = await ref
        .read(verifyOtpProvider)
        .call(
          email: email,
          token: token,
          purpose: purpose,
        );
    if (!ref.mounted) return;

    state = switch (result) {
      Success<void>() => const AsyncData<void>(null),
      FailureResult<void>(:final Failure failure) => AsyncError<void>(
        failure,
        StackTrace.current,
      ),
    };
  }

  /// No toca el estado: es secundario y no debe poner la pantalla a cargar.
  Future<Result<void>> resend({
    required String email,
    required OtpPurpose purpose,
  }) => ref.read(resendOtpProvider).call(email: email, purpose: purpose);
}

final AsyncNotifierProvider<VerifyCodeNotifier, void> verifyCodeProvider =
    AsyncNotifierProvider<VerifyCodeNotifier, void>(VerifyCodeNotifier.new);
