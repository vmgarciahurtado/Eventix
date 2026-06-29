/// Filtros aplicables al listado de eventos: categoría, ciudad y/o fecha.
class EventFilter {
  const EventFilter({this.categoryId, this.cityId, this.date});

  final int? categoryId;
  final int? cityId;
  final DateTime? date;

  bool get isEmpty => categoryId == null && cityId == null && date == null;

  /// Reemplaza campos. Para limpiar uno, pasa su flag `clear*` en `true`.
  EventFilter copyWith({
    int? categoryId,
    int? cityId,
    DateTime? date,
    bool clearCategory = false,
    bool clearCity = false,
    bool clearDate = false,
  }) {
    return EventFilter(
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      cityId: clearCity ? null : (cityId ?? this.cityId),
      date: clearDate ? null : (date ?? this.date),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is EventFilter &&
      other.categoryId == categoryId &&
      other.cityId == cityId &&
      other.date == date;

  @override
  int get hashCode => Object.hash(categoryId, cityId, date);
}
