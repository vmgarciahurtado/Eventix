class LocalShapeModel {
  const LocalShapeModel({
    required this.id,
    required this.name,
    required this.description,
  });

  final int id;
  final String name;
  final String description;

  factory LocalShapeModel.fromJson(Map<String, dynamic> json) =>
      LocalShapeModel(
        id: json['id'] as int,
        name: json['name'] as String,
        description: json['description'] as String,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'description': description,
  };
}
