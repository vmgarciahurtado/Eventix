class RemoteCategoryModel {
  const RemoteCategoryModel({
    required this.id,
    required this.name,
    required this.slug,
  });

  factory RemoteCategoryModel.fromJson(Map<String, dynamic> json) =>
      RemoteCategoryModel(
        id: (json['id'] as num).toInt(),
        name: json['name'] as String,
        slug: json['slug'] as String,
      );

  final int id;
  final String name;
  final String slug;
}
