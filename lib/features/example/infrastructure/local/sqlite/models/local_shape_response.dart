import 'package:eventix/features/example/infrastructure/local/sqlite/models/local_shape_model.dart';

class LocalShapeResponse {
  const LocalShapeResponse({required this.data});

  final List<LocalShapeModel> data;

  factory LocalShapeResponse.fromJson(Map<String, dynamic> json) =>
      LocalShapeResponse(
        data: (json['data'] as List<dynamic>)
            .map(
              (dynamic e) =>
                  LocalShapeModel.fromJson(e as Map<String, dynamic>),
            )
            .toList(),
      );
}
