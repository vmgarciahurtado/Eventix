import 'package:eventix/features/profile/domain/entities/app_user.dart';
import 'package:eventix/features/profile/infrastructure/models/remote_profile_model.dart';

abstract final class ProfileMapper {
  static AppUser toEntity(RemoteProfileModel m) => AppUser(
    id: m.id,
    firstName: m.firstName,
    lastName: m.lastName,
    onboardingCompleted: m.onboardingCompleted,
  );
}
