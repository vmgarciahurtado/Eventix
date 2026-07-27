import 'package:eventix/core/errors/supabase_guard.dart';
import 'package:eventix/features/auth/domain/enums/otp_purpose.dart';
import 'package:eventix/features/auth/infrastructure/datasources/auth_datasource.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Implementación de [AuthDatasource] sobre el cliente de Supabase.
///
/// Cada llamada se envuelve en [guardSupabaseCall], que traduce cualquier
/// excepción de Supabase a la jerarquía [Failure].
class SupabaseAuthDatasource implements AuthDatasource {
  const SupabaseAuthDatasource(this._client);

  final SupabaseClient _client;

  GoTrueClient get _auth => _client.auth;

  OtpType _otpType(OtpPurpose purpose) => switch (purpose) {
    OtpPurpose.signup => OtpType.signup,
    OtpPurpose.recovery => OtpType.recovery,
  };

  @override
  Future<void> signIn({required String email, required String password}) =>
      guardSupabaseCall(
        () => _auth.signInWithPassword(email: email, password: password),
      );

  @override
  Future<void> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) => guardSupabaseCall(
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
  }) => guardSupabaseCall(
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
  }) => guardSupabaseCall(() async {
    if (purpose == OtpPurpose.recovery) {
      await _auth.resetPasswordForEmail(email);
    } else {
      await _auth.resend(type: OtpType.signup, email: email);
    }
  });

  @override
  Future<void> sendPasswordReset({required String email}) =>
      guardSupabaseCall(() => _auth.resetPasswordForEmail(email));

  @override
  Future<void> updatePassword({required String newPassword}) =>
      guardSupabaseCall(
        () => _auth.updateUser(UserAttributes(password: newPassword)),
      );

  @override
  Future<void> signOut() => guardSupabaseCall(() => _auth.signOut());
}
