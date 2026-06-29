import 'package:eventix/features/auth/domain/entities/otp_purpose.dart';

/// Contrato del datasource de autenticación. La implementación concreta
/// (`SupabaseAuthDatasource`) traduce los errores de Supabase a `Failure`.
abstract interface class AuthDatasource {
  Future<void> signIn({required String email, required String password});

  Future<void> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  });

  Future<void> verifyOtp({
    required String email,
    required String token,
    required OtpPurpose purpose,
  });

  Future<void> resendOtp({
    required String email,
    required OtpPurpose purpose,
  });

  Future<void> sendPasswordReset({required String email});

  Future<void> updatePassword({required String newPassword});

  Future<void> signOut();

  /// Fila de `profiles` del usuario autenticado, o `null` si no hay sesión.
  Future<Map<String, dynamic>?> fetchCurrentProfile();

  Future<void> completeOnboarding();
}
