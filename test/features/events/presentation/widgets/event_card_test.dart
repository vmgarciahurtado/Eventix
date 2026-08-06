import 'package:eventix/features/events/presentation/widgets/event_card.dart';
import 'package:eventix/features/events/presentation/widgets/event_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  setUpAll(initSpanishDates);

  testWidgets('muestra título, ciudad, categoría, precio y fecha', (
    WidgetTester tester,
  ) async {
    await pumpComponent(
      tester,
      EventCard(event: tEvent(), onTap: () {}),
    );

    expect(find.text('Festival de Reggaetón'), findsOneWidget);
    expect(find.text('Bogotá'), findsOneWidget);
    expect(find.text('Reggaetón'), findsOneWidget);
    expect(find.text(r'$80.000'), findsOneWidget);
    expect(find.textContaining('4 jul'), findsOneWidget);
  });

  testWidgets('un evento gratuito dice "Gratis" en vez de un precio', (
    WidgetTester tester,
  ) async {
    await pumpComponent(
      tester,
      EventCard(event: tEvent(price: 0), onTap: () {}),
    );

    expect(find.text('Gratis'), findsOneWidget);
    expect(find.textContaining(r'$'), findsNothing);
  });

  testWidgets('tocar la tarjeta avisa una sola vez', (
    WidgetTester tester,
  ) async {
    int taps = 0;
    await pumpComponent(
      tester,
      EventCard(event: tEvent(), onTap: () => taps++),
    );

    await tester.tap(find.byType(EventCard));

    expect(taps, 1);
  });

  testWidgets('la imagen va dentro de un Hero para la transición', (
    WidgetTester tester,
  ) async {
    await pumpComponent(
      tester,
      EventCard(event: tEvent(id: 'evt-7'), onTap: () {}),
    );

    final Hero hero = tester.widget<Hero>(
      find.ancestor(of: find.byType(EventImage), matching: find.byType(Hero)),
    );
    expect(hero.tag, eventImageHeroTag('evt-7'));
  });

  testWidgets('un título largo se recorta en una línea', (
    WidgetTester tester,
  ) async {
    await pumpComponent(
      tester,
      EventCard(
        event: tEvent(
          title: 'Un nombre de fiesta absurdamente largo que no cabe nunca',
        ),
        onTap: () {},
      ),
    );

    final Text title = tester.widget<Text>(
      find.textContaining('Un nombre de fiesta'),
    );
    expect(title.maxLines, 1);
    expect(title.overflow, TextOverflow.ellipsis);
    expect(tester.takeException(), isNull);
  });
}
