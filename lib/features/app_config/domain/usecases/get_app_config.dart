import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/app_config/domain/entities/app_config.dart';
import 'package:eventix/features/app_config/domain/repositories/app_config_repository.dart';

class GetAppConfig {
  const GetAppConfig(this._repository);

  final AppConfigRepository _repository;

  Future<Result<AppConfig>> call() => _repository.load();
}
