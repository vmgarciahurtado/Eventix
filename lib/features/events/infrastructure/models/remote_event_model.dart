class RemoteEventModel {
  const RemoteEventModel({
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
    required this.imageUrl,
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
  final String? imageUrl;
}
