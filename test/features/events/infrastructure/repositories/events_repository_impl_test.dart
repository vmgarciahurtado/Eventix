import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/events/domain/entities/category.dart';
import 'package:eventix/features/events/domain/entities/event.dart';
import 'package:eventix/features/events/domain/entities/event_filter.dart';
import 'package:eventix/features/events/infrastructure/datasources/events_datasource.dart';
import 'package:eventix/features/events/infrastructure/models/remote_category_model.dart';
import 'package:eventix/features/events/infrastructure/models/remote_event_model.dart';
import 'package:eventix/features/events/infrastructure/repositories/events_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockEventsDatasource extends Mock implements EventsDatasource {}

RemoteEventModel _tEvent() => RemoteEventModel(
  id: 'evt-1',
  title: 'Festival',
  description: 'Una noche increíble',
  categoryId: 1,
  cityId: 2,
  categoryName: 'Reggaetón',
  cityName: 'Bogotá',
  startsAt: DateTime.utc(2026, 7, 4, 20),
  price: 80000,
  capacity: 300,
  imageUrl: 'https://cdn.test/festival.jpg',
);

void main() {
  late _MockEventsDatasource datasource;
  late EventsRepositoryImpl repository;

  setUpAll(() => registerFallbackValue(const EventFilter()));

  setUp(() {
    datasource = _MockEventsDatasource();
    repository = EventsRepositoryImpl(datasource);
  });

  test('getEvents maps remote models into Event entities', () async {
    when(
      () => datasource.fetchEvents(any()),
    ).thenAnswer((_) async => <RemoteEventModel>[_tEvent()]);

    final Result<List<Event>> result = await repository.getEvents(
      const EventFilter(),
    );

    expect(result, isA<Success<List<Event>>>());
    final List<Event> events = (result as Success<List<Event>>).data;
    expect(events, hasLength(1));
    expect(events.first.title, 'Festival');
    expect(events.first.categoryName, 'Reggaetón');
    expect(events.first.isFree, isFalse);
  });

  test('getCategories maps remote models into Category entities', () async {
    when(datasource.fetchCategories).thenAnswer(
      (_) async => <RemoteCategoryModel>[
        const RemoteCategoryModel(id: 1, name: 'Música', slug: 'musica'),
      ],
    );

    final Result<List<Category>> result = await repository.getCategories();

    expect(result, isA<Success<List<Category>>>());
    expect((result as Success<List<Category>>).data.first.name, 'Música');
  });
}
