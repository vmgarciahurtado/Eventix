import 'dart:async';
import 'dart:io';

import 'package:eventix/core/errors/failure.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Traduce los errores que lanza el cliente de Supabase a la jerarquía sellada
/// [Failure] de la app. Se usa dentro de `executeRepositoryCall` reemplazando
/// el mapeo de `DioException` del base.
Failure mapSupabaseError(Object error) {
  if (error is Failure) return error;

  if (error is AuthException) {
    return AuthFailure(_translateAuthMessage(error.message));
  }

  if (error is PostgrestException) {
    final String? code = error.code;
    if (code == 'PGRST116' || code == '404') {
      return const NotFoundFailure();
    }
    if (code == '23505') {
      return const ValidationFailure('El registro ya existe.');
    }
    if (code == '23514' || code == '23503') {
      return const ValidationFailure('Operación no permitida.');
    }
    return ServerFailure(error.message);
  }

  if (error is SocketException || error is TimeoutException) {
    return const ConnectionFailure();
  }
  if (error.toString().contains('SocketException') ||
      error.toString().contains('Failed host lookup')) {
    return const ConnectionFailure();
  }

  return UnexpectedFailure(error.toString());
}

String _translateAuthMessage(String raw) {
  final String msg = raw.toLowerCase();
  if (msg.contains('invalid login credentials')) {
    return 'Correo o contraseña incorrectos.';
  }
  if (msg.contains('email not confirmed')) {
    return 'Debes confirmar tu correo antes de iniciar sesión.';
  }
  if (msg.contains('user already registered') ||
      msg.contains('already been registered')) {
    return 'Este correo ya está registrado.';
  }
  if (msg.contains('token has expired') || msg.contains('expired')) {
    return 'El código expiró. Solicítalo de nuevo.';
  }
  if (msg.contains('invalid') && msg.contains('otp') ||
      msg.contains('token is invalid')) {
    return 'El código ingresado no es válido.';
  }
  if (msg.contains('password should be at least')) {
    return 'La contraseña es demasiado corta.';
  }
  if (msg.contains('rate limit') || msg.contains('too many')) {
    return 'Demasiados intentos. Espera un momento e inténtalo de nuevo.';
  }
  return raw;
}
