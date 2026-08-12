import 'package:eventix/features/app_config/domain/enums/banner_target.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reconoce los destinos del catálogo', () {
    expect(BannerTarget.parse('events'), BannerTarget.events);
    expect(BannerTarget.parse('reservations'), BannerTarget.reservations);
  });

  test('un destino inventado no manda a ninguna parte', () {
    expect(BannerTarget.parse('/ruta-que-no-existe'), BannerTarget.none);
    expect(BannerTarget.parse(null), BannerTarget.none);
  });
}
