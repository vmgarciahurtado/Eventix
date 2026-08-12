import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/core/helpers/json_map.dart';
import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/app_config/domain/entities/app_config.dart';
import 'package:eventix/features/app_config/infrastructure/datasources/app_config_datasource.dart';
import 'package:eventix/features/app_config/infrastructure/repositories/app_config_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockDatasource extends Mock implements AppConfigDatasource {}

void main() {
  late _MockDatasource datasource;
  late AppConfigRepositoryImpl repository;

  setUp(() {
    datasource = _MockDatasource();
    repository = AppConfigRepositoryImpl(datasource);
  });

  test('devuelve la configuración mapeada', () async {
    when(datasource.fetch).thenAnswer(
      (_) async => const JsonMap(<String, Object?>{'version': 5}),
    );

    final Result<AppConfig> result = await repository.load();

    expect(result, isA<Success<AppConfig>>());
    expect((result as Success<AppConfig>).data.version, 5);
  });

  test('un error del origen se convierte en Failure, no excepción', () async {
    when(datasource.fetch).thenThrow(const FormatException('json roto'));

    final Result<AppConfig> result = await repository.load();

    expect(result, isA<FailureResult<AppConfig>>());
    expect(
      (result as FailureResult<AppConfig>).failure,
      isA<UnexpectedFailure>(),
    );
  });

  test('invalidar delega en el origen', () async {
    when(datasource.invalidate).thenAnswer((_) async {});

    await repository.invalidate();

    verify(datasource.invalidate).called(1);
  });
}
