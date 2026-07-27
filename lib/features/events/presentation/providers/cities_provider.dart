import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/events/di/events_di.dart';
import 'package:eventix/features/events/domain/entities/city.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final FutureProvider<List<City>> citiesProvider = FutureProvider<List<City>>((
  Ref ref,
) async {
  final Result<List<City>> result = await ref.watch(getCitiesProvider).call();
  return switch (result) {
    Success<List<City>>(:final List<City> data) => data,
    FailureResult<List<City>>(:final Failure failure) => throw failure,
  };
});
