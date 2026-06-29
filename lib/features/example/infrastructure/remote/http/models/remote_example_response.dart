import 'package:eventix/features/example/infrastructure/remote/http/models/remote_example_model.dart';

class RemoteExampleResponse {
  const RemoteExampleResponse({required this.results});

  final List<RemoteExampleModel> results;

  factory RemoteExampleResponse.fromJson(Map<String, dynamic> json) =>
      RemoteExampleResponse(
        results: (json['results'] as List<dynamic>)
            .map(
              (dynamic e) =>
                  RemoteExampleModel.fromJson(e as Map<String, dynamic>),
            )
            .toList(),
      );
}
