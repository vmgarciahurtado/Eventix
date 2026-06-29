class LocalExampleModel {
  const LocalExampleModel({
    required this.id,
    required this.name,
    required this.description,
  });

  final int id;
  final String name;
  final String description;

  factory LocalExampleModel.fromJson(Map<String, dynamic> json) =>
      LocalExampleModel(
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
