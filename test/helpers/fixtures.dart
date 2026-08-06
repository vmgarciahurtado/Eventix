import 'package:eventix/features/events/domain/entities/category.dart';
import 'package:eventix/features/events/domain/entities/city.dart';
import 'package:eventix/features/events/domain/entities/event.dart';
import 'package:eventix/features/payments/domain/entities/checkout_session.dart';
import 'package:eventix/features/reservations/domain/entities/reservation.dart';
import 'package:eventix/features/reservations/domain/enums/reservation_status.dart';

Event tEvent({
  String id = 'evt-1',
  String title = 'Festival de Reggaetón',
  double price = 80000,
  int capacity = 300,
  String? imageUrl = 'https://cdn.test/festival.jpg',
  String cityName = 'Bogotá',
  String categoryName = 'Reggaetón',
  DateTime? startsAt,
}) => Event(
  id: id,
  title: title,
  description: 'Una noche increíble con los mejores exponentes del género.',
  categoryId: 1,
  cityId: 2,
  categoryName: categoryName,
  cityName: cityName,
  startsAt: startsAt ?? DateTime.utc(2026, 7, 4, 20),
  price: price,
  capacity: capacity,
  imageUrl: imageUrl,
);

Reservation tReservation({
  String id = 'res-1',
  String eventTitle = 'Festival de Reggaetón',
  int quantity = 2,
  ReservationStatus status = ReservationStatus.pending,
  DateTime? eventStartsAt,
}) => Reservation(
  id: id,
  eventTitle: eventTitle,
  quantity: quantity,
  status: status,
  createdAt: DateTime.utc(2026, 6, 29, 15),
  eventStartsAt: eventStartsAt ?? DateTime.utc(2026, 7, 4, 20),
);

const CheckoutSession tCheckoutSession = CheckoutSession(
  url: 'https://checkout.stripe.test/cs_test_123',
  sessionId: 'cs_test_123',
  returnUrlMarker: '/stripe-return',
);

const List<Category> tCategories = <Category>[
  Category(id: 1, name: 'Reggaetón'),
  Category(id: 2, name: 'Electrónica'),
];

const List<City> tCities = <City>[
  City(id: 1, name: 'Bogotá'),
  City(id: 2, name: 'Medellín'),
];
