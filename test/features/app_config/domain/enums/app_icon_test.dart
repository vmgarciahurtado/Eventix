import 'package:eventix/features/app_config/domain/enums/app_icon.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reconoce los nombres del catálogo', () {
    expect(AppIcon.parse('explore'), AppIcon.explore);
    expect(AppIcon.parse('party'), AppIcon.party);
  });

  test('un nombre desconocido cae al respaldo', () {
    expect(AppIcon.parse('cohete'), AppIcon.star);
  });

  test('quien llama puede elegir su propio respaldo', () {
    expect(
      AppIcon.parse(null, fallback: AppIcon.party),
      AppIcon.party,
    );
  });

  test('distingue mayúsculas: los nombres del JSON van en minúscula', () {
    expect(AppIcon.parse('Explore'), AppIcon.star);
  });
}
