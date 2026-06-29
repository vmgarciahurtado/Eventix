class RemoteCityModel {
  const RemoteCityModel({required this.id, required this.name});

  factory RemoteCityModel.fromJson(Map<String, dynamic> json) =>
      RemoteCityModel(
        id: (json['id'] as num).toInt(),
        name: json['name'] as String,
      );

  final int id;
  final String name;
}
