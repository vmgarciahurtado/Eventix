import 'dart:async';

import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/auth/di/auth_di.dart';
import 'package:eventix/features/reservations/presentation/providers/my_reservations_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LogoutNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> logout() async {
    if (state.isLoading) return;
    state = const AsyncLoading<void>();

    final Result<void> result = await ref.read(signOutProvider).call();
    if (!ref.mounted) return;

    state = switch (result) {
      Success<void>() => _clearSessionData(),
      FailureResult<void>(:final Failure failure) => AsyncError<void>(
        failure,
        StackTrace.current,
      ),
    };
  }

  AsyncData<void> _clearSessionData() {
    ref.invalidate(myReservationsProvider);
    return const AsyncData<void>(null);
  }
}

final AsyncNotifierProvider<LogoutNotifier, void> logoutProvider =
    AsyncNotifierProvider<LogoutNotifier, void>(LogoutNotifier.new);
