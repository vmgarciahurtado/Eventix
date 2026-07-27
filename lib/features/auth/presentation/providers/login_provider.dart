import 'dart:async';

import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/auth/di/auth_di.dart';
import 'package:eventix/features/auth/domain/enums/post_auth_destination.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Inicio de sesión. El estado es el destino al que navegar, `null` mientras
/// nadie ha entrado. `build` es síncrono: arranca inactivo, no cargando.
class LoginNotifier extends AsyncNotifier<PostAuthDestination?> {
  @override
  FutureOr<PostAuthDestination?> build() => null;

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    if (state.isLoading) return;
    state = const AsyncLoading<PostAuthDestination?>();

    final Result<PostAuthDestination> result = await _authenticate(
      email: email,
      password: password,
    );
    if (!ref.mounted) return;

    state = switch (result) {
      Success<PostAuthDestination>(:final PostAuthDestination data) =>
        AsyncData<PostAuthDestination?>(data),
      FailureResult<PostAuthDestination>(:final Failure failure) =>
        AsyncError<PostAuthDestination?>(failure, StackTrace.current),
    };
  }

  /// Autentica y, solo si la sesión se abrió, resuelve el destino.
  Future<Result<PostAuthDestination>> _authenticate({
    required String email,
    required String password,
  }) async {
    final Result<void> signedIn = await ref
        .read(signInProvider)
        .call(email: email, password: password);

    return switch (signedIn) {
      Success<void>() => Success<PostAuthDestination>(
        await ref.read(resolvePostAuthDestinationProvider).call(),
      ),
      FailureResult<void>(:final Failure failure) =>
        FailureResult<PostAuthDestination>(failure),
    };
  }
}

final AsyncNotifierProvider<LoginNotifier, PostAuthDestination?> loginProvider =
    AsyncNotifierProvider<LoginNotifier, PostAuthDestination?>(
      LoginNotifier.new,
    );
