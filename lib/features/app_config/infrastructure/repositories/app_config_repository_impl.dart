import 'package:eventix/core/helpers/execute_repository_call.dart';
import 'package:eventix/core/helpers/json_map.dart';
import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/app_config/domain/entities/app_config.dart';
import 'package:eventix/features/app_config/domain/repositories/app_config_repository.dart';
import 'package:eventix/features/app_config/infrastructure/datasources/app_config_datasource.dart';
import 'package:eventix/features/app_config/infrastructure/mappers/app_config_mapper.dart';

class AppConfigRepositoryImpl implements AppConfigRepository {
  const AppConfigRepositoryImpl(this._datasource);

  final AppConfigDatasource _datasource;

  @override
  Future<Result<AppConfig>> load() => executeRepositoryCall(() async {
    final JsonMap json = await _datasource.fetch();
    return AppConfigMapper.toEntity(json);
  });

  @override
  Future<void> invalidate() => _datasource.invalidate();
}
