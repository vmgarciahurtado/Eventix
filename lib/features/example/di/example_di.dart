import 'package:eventix/core/services/http/dio/dio_http_service.dart';
import 'package:eventix/core/services/http/dio/dio_provider.dart';
import 'package:eventix/core/services/sqlite/memory/sqlite_provider.dart';
import 'package:eventix/features/example/domain/usecases/get_examples.dart';
import 'package:eventix/features/example/infrastructure/local/sqlite/datasource/sqlite_example_datasource.dart';
import 'package:eventix/features/example/infrastructure/remote/http/datasource/http_example_datasource.dart';
import 'package:eventix/features/example/infrastructure/repositories/example_repository_impl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'example_di.g.dart';

@riverpod
HttpExampleDatasource exampleRemoteDatasource(Ref ref) =>
    HttpExampleDatasource(DioHttpService(ref.watch(dioProvider)));

@riverpod
SqliteExampleDatasource exampleLocalDatasource(Ref ref) =>
    SqliteExampleDatasource(ref.watch(sqliteServiceProvider));

@riverpod
ExampleRepositoryImpl exampleRepository(Ref ref) => ExampleRepositoryImpl(
  ref.watch(exampleRemoteDatasourceProvider),
  ref.watch(exampleLocalDatasourceProvider),
);

@riverpod
GetExamples getExamples(Ref ref) =>
    GetExamples(ref.watch(exampleRepositoryProvider));
