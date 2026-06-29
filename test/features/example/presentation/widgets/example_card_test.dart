import 'package:flutter/material.dart';
import 'package:eventix/features/example/domain/entities/example.dart';
import 'package:eventix/features/example/presentation/widgets/example_card.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildSubject({required Example example}) => MaterialApp(
    home: Scaffold(body: ExampleCard(example: example)),
  );

  group('ExampleCard', () {
    testWidgets(
      'given an example when ExampleCard builds '
      'then shows the id badge',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildSubject(example: _tExample()));

        expect(find.text('#1'), findsOneWidget);
      },
    );

    testWidgets(
      'given an example when ExampleCard builds '
      'then shows the example name',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildSubject(example: _tExample()));

        expect(find.text('Test Example'), findsOneWidget);
      },
    );

    testWidgets(
      'given an example when ExampleCard builds '
      'then shows the example description',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildSubject(example: _tExample()));

        expect(find.text('Test description'), findsOneWidget);
      },
    );

    testWidgets(
      'given an example when ExampleCard builds '
      'then renders inside a Card widget',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildSubject(example: _tExample()));

        expect(find.byType(Card), findsOneWidget);
      },
    );
  });
}

Example _tExample() => const Example(
  id: 1,
  name: 'Test Example',
  description: 'Test description',
);
