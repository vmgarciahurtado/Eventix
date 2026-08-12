import 'package:eventix/features/profile/domain/entities/app_user.dart';
import 'package:eventix/features/profile/infrastructure/models/remote_profile_model.dart';

abstract final class ProfileMapper {
  static RemoteProfileModel fromJson(Map<String, dynamic> json) {
    return RemoteProfileModel(
      id: json['id'] as String,
      email: (json['email'] as String?) ?? '',
      firstName: (json['first_name'] as String?) ?? '',
      lastName: (json['last_name'] as String?) ?? '',
      onboardingCompleted: (json['onboarding_completed'] as bool?) ?? false,
    );
  }

  static AppUser toEntity(RemoteProfileModel m) {
    return AppUser(
      id: m.id,
      firstName: m.firstName,
      lastName: m.lastName,
      onboardingCompleted: m.onboardingCompleted,
    );
  }
}
