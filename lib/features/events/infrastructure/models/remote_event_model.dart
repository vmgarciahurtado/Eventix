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
    required this.imageKey,
  });

  factory RemoteEventModel.fromJson(Map<String, dynamic> json) {
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
      imageKey: json['image_key'] as String?,
    );
  }

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
}
