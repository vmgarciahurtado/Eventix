import 'package:eventix/core/services/supabase/supabase_provider.dart';
import 'package:eventix/features/auth/domain/repositories/auth_repository.dart';
import 'package:eventix/features/auth/domain/usecases/register_user_use_case.dart';
import 'package:eventix/features/auth/domain/usecases/resend_otp_use_case.dart';
import 'package:eventix/features/auth/domain/usecases/resolve_post_auth_destination_use_case.dart';
import 'package:eventix/features/auth/domain/usecases/send_password_reset_use_case.dart';
import 'package:eventix/features/auth/domain/usecases/sign_in_use_case.dart';
import 'package:eventix/features/auth/domain/usecases/sign_out_use_case.dart';
import 'package:eventix/features/auth/domain/usecases/update_password_use_case.dart';
import 'package:eventix/features/auth/domain/usecases/verify_otp_use_case.dart';
import 'package:eventix/features/auth/infrastructure/datasources/auth_datasource.dart';
import 'package:eventix/features/auth/infrastructure/datasources/supabase_auth_datasource.dart';
import 'package:eventix/features/auth/infrastructure/repositories/auth_repository_impl.dart';
import 'package:eventix/features/profile/di/profile_di.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Composition root de la feature auth: expone SOLO interfaces.
final Provider<AuthDatasource> authDatasourceProvider =
    Provider<AuthDatasource>(
      (Ref ref) => SupabaseAuthDatasource(ref.watch(supabaseClientProvider)),
    );

final Provider<AuthRepository> authRepositoryProvider =
    Provider<AuthRepository>(
      (Ref ref) => AuthRepositoryImpl(ref.watch(authDatasourceProvider)),
    );

final Provider<SignInUseCase> signInProvider = Provider<SignInUseCase>(
  (Ref ref) => SignInUseCase(ref.watch(authRepositoryProvider)),
);

final Provider<RegisterUserUseCase> registerUserProvider =
    Provider<RegisterUserUseCase>(
      (Ref ref) => RegisterUserUseCase(ref.watch(authRepositoryProvider)),
    );

final Provider<VerifyOtpUseCase> verifyOtpProvider = Provider<VerifyOtpUseCase>(
  (Ref ref) => VerifyOtpUseCase(ref.watch(authRepositoryProvider)),
);

final Provider<ResendOtpUseCase> resendOtpProvider = Provider<ResendOtpUseCase>(
  (Ref ref) => ResendOtpUseCase(ref.watch(authRepositoryProvider)),
);

final Provider<SendPasswordResetUseCase> sendPasswordResetProvider =
    Provider<SendPasswordResetUseCase>(
      (Ref ref) => SendPasswordResetUseCase(ref.watch(authRepositoryProvider)),
    );

final Provider<UpdatePasswordUseCase> updatePasswordProvider =
    Provider<UpdatePasswordUseCase>(
      (Ref ref) => UpdatePasswordUseCase(ref.watch(authRepositoryProvider)),
    );

final Provider<SignOutUseCase> signOutProvider = Provider<SignOutUseCase>(
  (Ref ref) => SignOutUseCase(ref.watch(authRepositoryProvider)),
);

final Provider<ResolvePostAuthDestinationUseCase>
resolvePostAuthDestinationProvider =
    Provider<ResolvePostAuthDestinationUseCase>(
      (Ref ref) => ResolvePostAuthDestinationUseCase(
        ref.watch(profileRepositoryProvider),
      ),
    );
