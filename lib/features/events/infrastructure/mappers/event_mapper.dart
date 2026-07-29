import 'package:eventix/features/events/domain/entities/event.dart';
import 'package:eventix/features/events/infrastructure/models/remote_event_model.dart';

abstract final class EventMapper {
  static Event toEntity(RemoteEventModel m) => Event(
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
