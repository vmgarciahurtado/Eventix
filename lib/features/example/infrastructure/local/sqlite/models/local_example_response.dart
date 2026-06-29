import 'package:eventix/features/example/infrastructure/local/sqlite/models/local_example_model.dart';

class LocalExampleResponse {
  const LocalExampleResponse({required this.data});

  final List<LocalExampleModel> data;

  factory LocalExampleResponse.fromJson(Map<String, dynamic> json) =>
      LocalExampleResponse(
        data: (json['data'] as List<dynamic>)
            .map(
              (dynamic e) =>
                  LocalExampleModel.fromJson(e as Map<String, dynamic>),
            )
            .toList(),
      );
}
