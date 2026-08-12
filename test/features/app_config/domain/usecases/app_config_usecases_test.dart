import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/app_config/domain/entities/app_config.dart';
import 'package:eventix/features/app_config/domain/repositories/app_config_repository.dart';
import 'package:eventix/features/app_config/domain/usecases/get_app_config.dart';
import 'package:eventix/features/app_config/domain/usecases/reload_app_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepository extends Mock implements AppConfigRepository {}

/// Los dos casos de uso son delegaciones finas, así que van juntos.
void main() {
  late _MockRepository repository;

  setUp(() {
    repository = _MockRepository();
    when(repository.load).thenAnswer(
      (_) async => const Success<AppConfig>(AppConfig.fallback),
    );
    when(repository.invalidate).thenAnswer((_) async {});
  });

  test('GetAppConfig delega en el repositorio', () async {
    final Result<AppConfig> result = await GetAppConfig(repository).call();

    expect(result, isA<Success<AppConfig>>());
    verify(repository.load).called(1);
    verifyNever(repository.invalidate);
  });

  test('ReloadAppConfig invalida antes de leer', () async {
    await ReloadAppConfig(repository).call();

    verifyInOrder<void>(<void Function()>[
      repository.invalidate,
      repository.load,
    ]);
  });

  test('ReloadAppConfig propaga el fallo de la lectura', () async {
    when(repository.load).thenAnswer(
      (_) async =>
          const FailureResult<AppConfig>(UnexpectedFailure('sin archivo')),
    );

    final Result<AppConfig> result = await ReloadAppConfig(repository).call();

    expect(result, isA<FailureResult<AppConfig>>());
  });
}
