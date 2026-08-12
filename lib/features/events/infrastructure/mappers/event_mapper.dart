import 'package:eventix/features/events/domain/entities/event.dart';
import 'package:eventix/features/events/infrastructure/models/remote_event_model.dart';

abstract final class EventMapper {
  static RemoteEventModel fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? category =
        json['categories'] as Map<String, dynamic>?;
    final Map<String, dynamic>? city = json['cities'] as Map<String, dynamic>?;
    return RemoteEventModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: (json['description'] as String?) ?? '',
      categoryId: (json['category_id'] as num?)?.toInt(),
      cityId: (json['city_id'] as num?)?.toInt(),
      categoryName: (category?['name'] as String?) ?? '',
      cityName: (city?['name'] as String?) ?? '',
      startsAt: DateTime.parse(json['starts_at'] as String),
      price: (json['price'] as num?)?.toDouble() ?? 0,
      capacity: (json['capacity'] as num?)?.toInt() ?? 0,
      imageUrl: json['image_url'] as String?,
    );
  }

  static Event toEntity(RemoteEventModel m) {
    return Event(
      id: m.id,
      title: m.title,
      description: m.description,
      categoryId: m.categoryId,
      cityId: m.cityId,
      categoryName: m.categoryName,
      cityName: m.cityName,
      startsAt: m.startsAt,
      price: m.price,
      capacity: m.capacity,
      imageUrl: m.imageUrl,
    );
  }
}
