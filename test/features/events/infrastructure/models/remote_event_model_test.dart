import 'package:eventix/features/events/infrastructure/models/remote_event_model.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _tFullJson() => <String, dynamic>{
  'id': 'evt-1',
  'title': 'Festival Indie',
  'description': 'Bandas independientes',
  'category_id': 1,
  'city_id': 2,
  'categories': <String, dynamic>{'name': 'Reggaetón'},
  'cities': <String, dynamic>{'name': 'Medellín'},
  'starts_at': '2026-07-04T20:00:00Z',
  'price': 80000,
  'capacity': 300,
  'image_url': 'https://cdn.test/festival_indie.jpg',
};

void main() {
  group('RemoteEventModel.fromJson', () {
    test('parses a complete row with joined category and city names', () {
      final RemoteEventModel model = RemoteEventModel.fromJson(_tFullJson());

      expect(model.id, 'evt-1');
      expect(model.title, 'Festival Indie');
      expect(model.categoryId, 1);
      expect(model.cityId, 2);
      expect(model.categoryName, 'Reggaetón');
      expect(model.cityName, 'Medellín');
      expect(model.startsAt, DateTime.utc(2026, 7, 4, 20));
      expect(model.price, 80000.0);
      expect(model.capacity, 300);
      expect(model.imageUrl, 'https://cdn.test/festival_indie.jpg');
    });

    test('applies defaults when optional/nested fields are missing', () {
      final RemoteEventModel model = RemoteEventModel.fromJson(
        <String, dynamic>{
          'id': 'evt-2',
          'title': 'Evento sin extras',
          'starts_at': '2026-07-04T20:00:00Z',
        },
      );

      expect(model.description, '');
      expect(model.categoryId, isNull);
      expect(model.cityId, isNull);
      expect(model.categoryName, '');
      expect(model.cityName, '');
      expect(model.price, 0.0);
      expect(model.capacity, 0);
      expect(model.imageUrl, isNull);
    });

    test('coerces numeric price and capacity from int or double', () {
      final RemoteEventModel model = RemoteEventModel.fromJson(
        <String, dynamic>{
          'id': 'evt-3',
          'title': 'Precios raros',
          'starts_at': '2026-07-04T20:00:00Z',
          'price': 99.99,
          'capacity': 10,
        },
      );
      expect(model.price, 99.99);
      expect(model.capacity, 10);
    });

    test('throws when a required field is missing', () {
      expect(
        () => RemoteEventModel.fromJson(<String, dynamic>{'title': 'no id'}),
        throwsA(isA<TypeError>()),
      );
    });

    test('throws when starts_at is not a valid date', () {
      expect(
        () => RemoteEventModel.fromJson(<String, dynamic>{
          'id': 'evt-4',
          'title': 'Fecha inválida',
          'starts_at': 'not-a-date',
        }),
        throwsFormatException,
      );
    });
  });
}
