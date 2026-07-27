import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/profile/domain/entities/app_user.dart';

abstract interface class ProfileRepository {
  Future<Result<AppUser?>> currentProfile();
  Future<Result<void>> completeOnboarding();
}
