import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/auth/domain/entities/app_user.dart';
import 'package:eventix/features/auth/domain/entities/otp_purpose.dart';

/// Contrato de autenticación. La implementación concreta usa Supabase.
abstract interface class AuthRepository {
  Future<Result<void>> signIn({
    required String email,
    required String password,
  });

  /// Registra al usuario y dispara el envío del código OTP por correo.
  Future<Result<void>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  });

  Future<Result<void>> verifyOtp({
    required String email,
    required String token,
    required OtpPurpose purpose,
  });

  Future<Result<void>> resendOtp({
    required String email,
    required OtpPurpose purpose,
  });

  Future<Result<void>> sendPasswordReset({required String email});

  Future<Result<void>> updatePassword({required String newPassword});

  Future<Result<void>> signOut();

  /// Perfil del usuario autenticado (o `null` si no hay sesión).
  Future<Result<AppUser?>> currentProfile();

  Future<Result<void>> completeOnboarding();
}
