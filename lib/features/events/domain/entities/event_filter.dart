/// Filtros aplicables al listado de eventos: categoría, ciudad y/o fecha.
class EventFilter {
  const EventFilter({this.categoryId, this.cityId, this.date});

  final int? categoryId;
  final int? cityId;
  final DateTime? date;

  bool get isEmpty => categoryId == null && cityId == null && date == null;
}
