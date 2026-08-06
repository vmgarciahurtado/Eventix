import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/features/profile/infrastructure/datasources/supabase_profile_datasource.dart';
import 'package:eventix/features/profile/infrastructure/models/remote_profile_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import '../../../../helpers/fake_supabase.dart';

const String _uid = 'user-1';

const Map<String, dynamic> _session = <String, dynamic>{
  'access_token': 'token-de-prueba',
  'token_type': 'bearer',
  'expires_in': 3600,
  'refresh_token': 'refresh-de-prueba',
  'user': <String, dynamic>{
    'id': _uid,
    'aud': 'authenticated',
    'role': 'authenticated',
    'email': 'victor@correo.com',
    'app_metadata': <String, dynamic>{},
    'user_metadata': <String, dynamic>{},
    'created_at': '2026-01-01T00:00:00Z',
  },
};

Map<String, dynamic> _profileRow({bool onboardingCompleted = true}) =>
    <String, dynamic>{
      'id': _uid,
      'email': 'victor@correo.com',
      'first_name': 'Victor',
      'last_name': 'García',
      'onboarding_completed': onboardingCompleted,
    };

void main() {
  late FakeSupabase supabase;

  /// El perfil se scopea con `auth.currentUser`: hay que abrir sesión primero.
  Future<void> signIn() => supabase.client.auth.signInWithPassword(
    email: 'victor@correo.com',
    password: 'secreta1',
  );

  SupabaseProfileDatasource datasource() =>
      SupabaseProfileDatasource(supabase.client);

  group('sin sesión', () {
    setUp(() {
      supabase = FakeSupabase.replying(<Map<String, dynamic>>[]);
      addTearDown(supabase.dispose);
    });

    test('no consulta el perfil y falla como no autorizado', () async {
      await expectLater(
        datasource().fetchCurrentProfile(),
        throwsA(isA<UnauthorizedFailure>()),
      );

      // Sin sesión, consultar `profiles` traería vacío por RLS, no el error.
      expect(supabase.requests, isEmpty);
    });

    test('tampoco intenta marcar el onboarding', () async {
      await expectLater(
        datasource().completeOnboarding(),
        throwsA(isA<UnauthorizedFailure>()),
      );

      expect(supabase.requests, isEmpty);
    });
  });

  group('con sesión', () {
    setUp(() {
      supabase = FakeSupabase((http.Request request) {
        if (request.url.path.contains('/auth/')) return jsonResponse(_session);
        if (request.method == 'PATCH') {
          return jsonResponse(<Map<String, dynamic>>[]);
        }
        return jsonResponse(_profileRow());
      });
      addTearDown(supabase.dispose);
    });

    test('trae la fila del usuario en sesión, no la de cualquiera', () async {
      await signIn();

      final RemoteProfileModel? profile = await datasource()
          .fetchCurrentProfile();

      expect(supabase.lastUri.path, endsWith('/rest/v1/profiles'));
      expect(supabase.lastQuery['id'], 'eq.$_uid');
      expect(profile?.firstName, 'Victor');
      expect(profile?.onboardingCompleted, isTrue);
    });

    test('si el perfil todavía no existe devuelve null sin romper', () async {
      supabase = FakeSupabase((http.Request request) {
        if (request.url.path.contains('/auth/')) return jsonResponse(_session);
        return jsonResponse(null);
      });
      addTearDown(supabase.dispose);
      await signIn();

      expect(await datasource().fetchCurrentProfile(), isNull);
    });

    test('completar el onboarding actualiza solo esa bandera', () async {
      await signIn();

      await datasource().completeOnboarding();

      expect(supabase.lastRequest.method, 'PATCH');
      expect(supabase.lastUri.path, endsWith('/rest/v1/profiles'));
      expect(supabase.lastQuery['id'], 'eq.$_uid');
      expect(supabase.lastBody, <String, dynamic>{
        'onboarding_completed': true,
      });
    });

    test('un error del servidor se traduce a Failure', () async {
      await signIn();
      supabase = FakeSupabase.failing();
      addTearDown(supabase.dispose);

      // El cliente nuevo no tiene sesión: el fallo llega igual como Failure.
      await expectLater(
        datasource().fetchCurrentProfile(),
        throwsA(isA<Failure>()),
      );
    });
  });
}
