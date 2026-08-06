import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  test('un precio en cero es un evento gratuito', () {
    expect(tEvent(price: 0).isFree, isTrue);
  });

  test('cualquier precio positivo deja de ser gratuito', () {
    expect(tEvent(price: 1).isFree, isFalse);
    expect(tEvent().isFree, isFalse);
  });

  test('un precio negativo cuenta como gratuito', () {
    // Ante un dato malo, no cobrar es el lado seguro del error.
    expect(tEvent(price: -1).isFree, isTrue);
  });
}
