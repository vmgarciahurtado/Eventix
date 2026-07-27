import 'package:eventix/features/events/domain/entities/city.dart';
import 'package:eventix/features/events/infrastructure/models/remote_city_model.dart';

abstract final class CityMapper {
  static City toEntity(RemoteCityModel m) => City(id: m.id, name: m.name);
}
