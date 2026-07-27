import 'package:eventix/features/profile/infrastructure/models/remote_profile_model.dart';

abstract interface class ProfileDatasource {
  Future<RemoteProfileModel?> fetchCurrentProfile();

  Future<void> completeOnboarding();
}
