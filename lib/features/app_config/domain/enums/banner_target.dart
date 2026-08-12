/// Destinos a los que puede llevar el botón del banner.
///
/// Es un enum y no una ruta libre para que el JSON no pueda mandar a la app a
/// una ruta inexistente.
enum BannerTarget {
  none,
  events,
  reservations;

  static BannerTarget parse(String? name) {
    for (final BannerTarget target in BannerTarget.values) {
      if (target.name == name) return target;
    }
    return BannerTarget.none;
  }
}
