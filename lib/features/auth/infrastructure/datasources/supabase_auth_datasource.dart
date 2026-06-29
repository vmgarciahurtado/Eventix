import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/core/errors/map_supabase_error.dart';
import 'package:eventix/features/auth/domain/entities/otp_purpose.dart';
import 'package:eventix/features/auth/infrastructure/datasources/auth_datasource.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Implementación de [AuthDatasource] sobre el cliente de Supabase.
///
/// Cada llamada se envuelve en [_guard], que traduce cualquier excepción de
/// Supabase a la jerarquía [Failure] mediante [mapSupabaseError].
class SupabaseAuthDatasource implements AuthDatasource {
  const SupabaseAuthDatasource(this._client);

  final SupabaseClient _client;

  GoTrueClient get _auth => _client.auth;

  Future<T> _guard<T>(Future<T> Function() fn) async {
    try {
      return await fn();
    } catch (e) {
      throw mapSupabaseError(e);
    }
  }

  OtpType _otpType(OtpPurpose purpose) => switch (purpose) {
    OtpPurpose.signup => OtpType.signup,
    OtpPurpose.recovery => OtpType.recovery,
  };

  @override
  Future<void> signIn({required String email, required String password}) =>
      _guard(() => _auth.signInWithPassword(email: email, password: password));

  @override
  Future<void> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) => _guard(
    () => _auth.signUp(
      email: email,
      password: password,
      data: <String, dynamic>{
        'first_name': firstName,
        'last_name': lastName,
      },
    ),
  );

  @override
  Future<void> verifyOtp({
    required String email,
    required String token,
    required OtpPurpose purpose,
  }) => _guard(
    () => _auth.verifyOTP(
      email: email,
      token: token,
      type: _otpType(purpose),
    ),
  );

  @override
  Future<void> resendOtp({
    required String email,
    required OtpPurpose purpose,
  }) => _guard(() async {
    if (purpose == OtpPurpose.recovery) {
      await _auth.resetPasswordForEmail(email);
    } else {
      await _auth.resend(type: OtpType.signup, email: email);
    }
  });

  @override
  Future<void> sendPasswordReset({required String email}) =>
      _guard(() => _auth.resetPasswordForEmail(email));

  @override
  Future<void> updatePassword({required String newPassword}) =>
      _guard(() => _auth.updateUser(UserAttributes(password: newPassword)));

  @override
  Future<void> signOut() => _guard(() => _auth.signOut());

  @override
  Future<Map<String, dynamic>?> fetchCurrentProfile() => _guard(() async {
    final String? uid = _auth.currentUser?.id;
    if (uid == null) return null;
    return _client.from('profiles').select().eq('id', uid).maybeSingle();
  });

  @override
  Future<void> completeOnboarding() => _guard(() async {
    final String? uid = _auth.currentUser?.id;
    if (uid == null) throw const UnauthorizedFailure();
    await _client
        .from('profiles')
        .update(<String, dynamic>{'onboarding_completed': true})
        .eq('id', uid);
  });
}
