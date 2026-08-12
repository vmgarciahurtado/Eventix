import 'package:eventix/features/events/domain/entities/city.dart';
import 'package:eventix/features/events/infrastructure/models/remote_city_model.dart';

abstract final class CityMapper {
  static RemoteCityModel fromJson(Map<String, dynamic> json) {
    return RemoteCityModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
    );
  }

  static City toEntity(RemoteCityModel m) => City(id: m.id, name: m.name);
}
