import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/events/di/events_di.dart';
import 'package:eventix/features/events/domain/entities/category.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final FutureProvider<List<Category>> categoriesProvider =
    FutureProvider<List<Category>>((Ref ref) async {
      final Result<List<Category>> result = await ref
          .watch(getCategoriesProvider)
          .call();
      return switch (result) {
        Success<List<Category>>(:final List<Category> data) => data,
        FailureResult<List<Category>>(:final Failure failure) => throw failure,
      };
    });
