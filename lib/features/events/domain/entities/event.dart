/// Evento del catálogo.
class Event {
  const Event({
    required this.id,
    required this.title,
    required this.description,
    required this.categoryId,
    required this.cityId,
    required this.categoryName,
    required this.cityName,
    required this.startsAt,
    required this.price,
    required this.capacity,
    this.imageKey,
  });

  final String id;
  final String title;
  final String description;
  final int? categoryId;
  final int? cityId;
  final String categoryName;
  final String cityName;
  final DateTime startsAt;
  final double price;
  final int capacity;
  final String? imageKey;

  bool get isFree => price <= 0;
}
