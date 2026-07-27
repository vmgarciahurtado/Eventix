import 'package:eventix/core/helpers/execute_repository_call.dart';
import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/profile/domain/entities/app_user.dart';
import 'package:eventix/features/profile/domain/repositories/profile_repository.dart';
import 'package:eventix/features/profile/infrastructure/datasources/profile_datasource.dart';
import 'package:eventix/features/profile/infrastructure/mappers/profile_mapper.dart';
import 'package:eventix/features/profile/infrastructure/models/remote_profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl(this._datasource);

  final ProfileDatasource _datasource;

  @override
  Future<Result<AppUser?>> currentProfile() => executeRepositoryCall(() async {
    final RemoteProfileModel? model = await _datasource.fetchCurrentProfile();
    return model == null ? null : ProfileMapper.toEntity(model);
  });

  @override
  Future<Result<void>> completeOnboarding() =>
      executeRepositoryCall(() => _datasource.completeOnboarding());
}
