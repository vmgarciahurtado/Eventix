import 'dart:convert';

import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/features/auth/domain/enums/otp_purpose.dart';
import 'package:eventix/features/auth/infrastructure/datasources/supabase_auth_datasource.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import '../../../../helpers/fake_supabase.dart';

const Map<String, dynamic> _user = <String, dynamic>{
  'id': 'user-1',
  'aud': 'authenticated',
  'role': 'authenticated',
  'email': 'victor@correo.com',
  'app_metadata': <String, dynamic>{},
  'user_metadata': <String, dynamic>{},
  'created_at': '2026-01-01T00:00:00Z',
};

const Map<String, dynamic> _session = <String, dynamic>{
  'access_token': 'token-de-prueba',
  'token_type': 'bearer',
  'expires_in': 3600,
  'refresh_token': 'refresh-de-prueba',
  'user': _user,
};

/// GoTrue responde distinto según el endpoint: sesión, usuario o vacío.
http.Response _gotrue(http.Request request) {
  final String path = request.url.path;
  if (path.endsWith('/user')) return jsonResponse(_user);
  if (path.endsWith('/logout')) return jsonResponse(<String, dynamic>{});
  if (path.endsWith('/recover') || path.endsWith('/resend')) {
    return jsonResponse(<String, dynamic>{});
  }
  return jsonResponse(_session);
}

void main() {
  late FakeSupabase supabase;

  setUp(() {
    supabase = FakeSupabase(_gotrue);
    addTearDown(supabase.dispose);
  });

  SupabaseAuthDatasource datasource() =>
      SupabaseAuthDatasource(supabase.client);

  test('signIn pide un token con las credenciales', () async {
    await datasource().signIn(email: 'victor@correo.com', password: 'secreta1');

    expect(supabase.lastUri.path, endsWith('/auth/v1/token'));
    expect(supabase.lastUri.queryParameters['grant_type'], 'password');
    expect(supabase.lastBody['email'], 'victor@correo.com');
    expect(supabase.lastBody['password'], 'secreta1');
  });

  test('signUp manda nombre y apellido como metadatos del usuario', () async {
    await datasource().signUp(
      email: 'victor@correo.com',
      password: 'secreta1',
      firstName: 'Victor',
      lastName: 'García',
    );

    expect(supabase.lastUri.path, endsWith('/auth/v1/signup'));
    // El trigger de la BD arma la fila de `profiles` con estos dos campos.
    expect(supabase.lastBody['data'], <String, dynamic>{
      'first_name': 'Victor',
      'last_name': 'García',
    });
  });

  test('verifyOtp de registro pide el tipo signup', () async {
    await datasource().verifyOtp(
      email: 'victor@correo.com',
      token: '12345678',
      purpose: OtpPurpose.signup,
    );

    expect(supabase.lastUri.path, endsWith('/auth/v1/verify'));
    expect(supabase.lastBody['type'], 'signup');
    expect(supabase.lastBody['token'], '12345678');
  });

  test('verifyOtp de recuperación pide el tipo recovery', () async {
    // Con el tipo equivocado Supabase rechaza el código aunque sea correcto.
    await datasource().verifyOtp(
      email: 'victor@correo.com',
      token: '12345678',
      purpose: OtpPurpose.recovery,
    );

    expect(supabase.lastBody['type'], 'recovery');
  });

  test('reenviar en registro usa el endpoint de reenvío', () async {
    await datasource().resendOtp(
      email: 'victor@correo.com',
      purpose: OtpPurpose.signup,
    );

    expect(supabase.lastUri.path, endsWith('/auth/v1/resend'));
    expect(supabase.lastBody['type'], 'signup');
  });

  test('reenviar en recuperación usa el endpoint de recuperación', () async {
    // No son intercambiables: `resend` solo sirve para confirmar el registro.
    await datasource().resendOtp(
      email: 'victor@correo.com',
      purpose: OtpPurpose.recovery,
    );

    expect(supabase.lastUri.path, endsWith('/auth/v1/recover'));
  });

  test('sendPasswordReset dispara el correo de recuperación', () async {
    await datasource().sendPasswordReset(email: 'victor@correo.com');

    expect(supabase.lastUri.path, endsWith('/auth/v1/recover'));
    expect(supabase.lastBody['email'], 'victor@correo.com');
  });

  test('updatePassword actualiza el usuario en sesión', () async {
    // Cambiar la contraseña exige la sesión que abre el código de recuperación.
    await datasource().signIn(email: 'victor@correo.com', password: 'vieja');

    await datasource().updatePassword(newPassword: 'nueva-secreta');

    expect(supabase.lastUri.path, endsWith('/auth/v1/user'));
    expect(supabase.lastRequest.method, 'PUT');
    expect(supabase.lastBody['password'], 'nueva-secreta');
  });

  test('sin sesión, cambiar la contraseña falla en vez de pasar callado',
      () async {
    await expectLater(
      datasource().updatePassword(newPassword: 'nueva-secreta'),
      throwsA(isA<Failure>()),
    );
  });

  test('signOut no revienta cuando no hay sesión que cerrar', () async {
    await datasource().signOut();
  });

  group('errores', () {
    test('credenciales inválidas se traducen a AuthFailure', () async {
      supabase = FakeSupabase(
        (http.Request _) => http.Response(
          jsonEncode(<String, dynamic>{
            'error': 'invalid_grant',
            'error_description': 'Invalid login credentials',
          }),
          400,
          headers: <String, String>{'content-type': 'application/json'},
        ),
      );
      addTearDown(supabase.dispose);

      await expectLater(
        datasource().signIn(email: 'victor@correo.com', password: 'mala'),
        throwsA(isA<Failure>()),
      );
    });

    test('un 500 del servidor también sale como Failure', () async {
      supabase = FakeSupabase.failing();
      addTearDown(supabase.dispose);

      await expectLater(
        datasource().sendPasswordReset(email: 'victor@correo.com'),
        throwsA(isA<Failure>()),
      );
    });
  });
}
