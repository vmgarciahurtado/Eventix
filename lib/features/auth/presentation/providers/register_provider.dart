import 'dart:async';

import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/auth/di/auth_di.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Registro de un usuario nuevo. El estado es el correo pendiente de
/// verificar, con el que la página navega a la verificación.
class RegisterNotifier extends AsyncNotifier<String?> {
  @override
  FutureOr<String?> build() => null;

  Future<void> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    if (state.isLoading) return;
    state = const AsyncLoading<String?>();

    final Result<void> result = await ref
        .read(registerUserProvider)
        .call(
          email: email,
          password: password,
          firstName: firstName,
          lastName: lastName,
        );
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

final AsyncNotifierProvider<RegisterNotifier, String?> registerProvider =
    AsyncNotifierProvider<RegisterNotifier, String?>(RegisterNotifier.new);
