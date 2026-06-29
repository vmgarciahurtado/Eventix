import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/example/di/example_di.dart';
import 'package:eventix/features/example/domain/entities/example.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'examples_provider.g.dart';

@riverpod
class ExamplesNotifier extends _$ExamplesNotifier {
  @override
  Future<List<Example>> build() async {
    final Result<List<Example>> result =
        await ref.watch(getExamplesProvider).call();
    return switch (result) {
      Success<List<Example>>(:final List<Example> data) => data,
      FailureResult<List<Example>>(:final Failure failure) => throw failure,
    };
  }
}
