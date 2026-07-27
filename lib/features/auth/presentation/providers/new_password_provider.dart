import 'dart:async';

import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/auth/di/auth_di.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NewPasswordNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> updatePassword({required String newPassword}) async {
    if (state.isLoading) return;
    state = const AsyncLoading<void>();

    final Result<void> result = await ref
        .read(updatePasswordProvider)
        .call(newPassword: newPassword);
    if (!ref.mounted) return;

    state = switch (result) {
      Success<void>() => const AsyncData<void>(null),
      FailureResult<void>(:final Failure failure) => AsyncError<void>(
        failure,
        StackTrace.current,
      ),
    };
  }
}

final AsyncNotifierProvider<NewPasswordNotifier, void> newPasswordProvider =
    AsyncNotifierProvider<NewPasswordNotifier, void>(NewPasswordNotifier.new);
