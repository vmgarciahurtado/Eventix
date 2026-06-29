class RemoteExampleModel {
  const RemoteExampleModel({
    required this.id,
    required this.name,
    required this.description,
  });

  final int id;
  final String name;
  final String description;

  factory RemoteExampleModel.fromJson(Map<String, dynamic> json) =>
      RemoteExampleModel(
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
