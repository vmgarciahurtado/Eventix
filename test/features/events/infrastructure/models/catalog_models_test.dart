import 'package:eventix/features/events/domain/entities/category.dart';
import 'package:eventix/features/events/domain/entities/city.dart';
import 'package:eventix/features/events/infrastructure/mappers/category_mapper.dart';
import 'package:eventix/features/events/infrastructure/mappers/city_mapper.dart';
import 'package:eventix/features/events/infrastructure/models/remote_category_model.dart';
import 'package:eventix/features/events/infrastructure/models/remote_city_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RemoteCategoryModel', () {
    test('parsea la fila del catálogo', () {
      final RemoteCategoryModel model = RemoteCategoryModel.fromJson(
        <String, dynamic>{'id': 1, 'name': 'Reggaetón', 'slug': 'reggaeton'},
      );

      expect(model.id, 1);
      expect(model.name, 'Reggaetón');
      expect(model.slug, 'reggaeton');
    });

    test('acepta el id como double', () {
      expect(
        RemoteCategoryModel.fromJson(<String, dynamic>{
          'id': 1.0,
          'name': 'Rock',
          'slug': 'rock',
        }).id,
        1,
      );
    });

    test('lanza si falta el nombre', () {
      expect(
        () => RemoteCategoryModel.fromJson(<String, dynamic>{
          'id': 1,
          'slug': 'rock',
        }),
        throwsA(isA<TypeError>()),
      );
    });

    test('el mapper descarta el slug: el dominio no lo usa', () {
      final Category category = CategoryMapper.toEntity(
        const RemoteCategoryModel(id: 3, name: 'Salsa', slug: 'salsa'),
      );

      expect(category.id, 3);
      expect(category.name, 'Salsa');
    });
  });

  group('RemoteCityModel', () {
    test('parsea la fila y la mapea a la entidad', () {
      final RemoteCityModel model = RemoteCityModel.fromJson(
        <String, dynamic>{'id': 2, 'name': 'Medellín'},
      );
      final City city = CityMapper.toEntity(model);

      expect(city.id, 2);
      expect(city.name, 'Medellín');
    });

    test('lanza si falta el nombre', () {
      expect(
        () => RemoteCityModel.fromJson(<String, dynamic>{'id': 2}),
        throwsA(isA<TypeError>()),
      );
    });
  });
}
