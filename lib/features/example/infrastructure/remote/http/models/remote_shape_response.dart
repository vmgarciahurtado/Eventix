import 'package:eventix/features/example/infrastructure/remote/http/models/remote_shape_model.dart';

class RemoteShapeResponse {
  const RemoteShapeResponse({required this.results});

  final List<RemoteShapeModel> results;

  factory RemoteShapeResponse.fromJson(Map<String, dynamic> json) =>
      RemoteShapeResponse(
        results: (json['results'] as List<dynamic>)
            .map(
              (dynamic e) =>
                  RemoteShapeModel.fromJson(e as Map<String, dynamic>),
            )
            .toList(),
      );
}
