import 'package:eventix/core/services/supabase/supabase_provider.dart';
import 'package:eventix/features/auth/domain/repositories/auth_repository.dart';
import 'package:eventix/features/auth/domain/usecases/complete_onboarding.dart';
import 'package:eventix/features/auth/domain/usecases/get_current_profile.dart';
import 'package:eventix/features/auth/domain/usecases/register_user.dart';
import 'package:eventix/features/auth/domain/usecases/resend_otp.dart';
import 'package:eventix/features/auth/domain/usecases/send_password_reset.dart';
import 'package:eventix/features/auth/domain/usecases/sign_in.dart';
import 'package:eventix/features/auth/domain/usecases/sign_out.dart';
import 'package:eventix/features/auth/domain/usecases/update_password.dart';
import 'package:eventix/features/auth/domain/usecases/verify_otp.dart';
import 'package:eventix/features/auth/infrastructure/datasources/auth_datasource.dart';
import 'package:eventix/features/auth/infrastructure/datasources/supabase_auth_datasource.dart';
import 'package:eventix/features/auth/infrastructure/repositories/auth_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- Infraestructura ---
final Provider<AuthDatasource> authDatasourceProvider =
    Provider<AuthDatasource>(
      (Ref ref) => SupabaseAuthDatasource(ref.watch(supabaseClientProvider)),
    );

final Provider<AuthRepository> authRepositoryProvider =
    Provider<AuthRepository>(
      (Ref ref) => AuthRepositoryImpl(ref.watch(authDatasourceProvider)),
    );

// --- Casos de uso ---
final Provider<SignIn> signInProvider =
    Provider<SignIn>((Ref ref) => SignIn(ref.watch(authRepositoryProvider)));

final Provider<RegisterUser> registerUserProvider = Provider<RegisterUser>(
  (Ref ref) => RegisterUser(ref.watch(authRepositoryProvider)),
);

final Provider<VerifyOtp> verifyOtpProvider = Provider<VerifyOtp>(
  (Ref ref) => VerifyOtp(ref.watch(authRepositoryProvider)),
);

final Provider<ResendOtp> resendOtpProvider = Provider<ResendOtp>(
  (Ref ref) => ResendOtp(ref.watch(authRepositoryProvider)),
);

final Provider<SendPasswordReset> sendPasswordResetProvider =
    Provider<SendPasswordReset>(
      (Ref ref) => SendPasswordReset(ref.watch(authRepositoryProvider)),
    );

final Provider<UpdatePassword> updatePasswordProvider =
    Provider<UpdatePassword>(
      (Ref ref) => UpdatePassword(ref.watch(authRepositoryProvider)),
    );

final Provider<SignOut> signOutProvider =
    Provider<SignOut>((Ref ref) => SignOut(ref.watch(authRepositoryProvider)));

final Provider<GetCurrentProfile> getCurrentProfileProvider =
    Provider<GetCurrentProfile>(
      (Ref ref) => GetCurrentProfile(ref.watch(authRepositoryProvider)),
    );

final Provider<CompleteOnboarding> completeOnboardingProvider =
    Provider<CompleteOnboarding>(
      (Ref ref) => CompleteOnboarding(ref.watch(authRepositoryProvider)),
    );
