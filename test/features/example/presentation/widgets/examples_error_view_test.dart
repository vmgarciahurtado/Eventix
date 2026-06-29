import 'package:flutter/material.dart';
import 'package:eventix/features/example/presentation/widgets/examples_error_view.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildSubject({required String message, VoidCallback? onRetry}) =>
      MaterialApp(
        home: Scaffold(
          body: ExamplesErrorView(message: message, onRetry: onRetry),
        ),
      );

  group('ExamplesErrorView', () {
    testWidgets(
      'given a message when ExamplesErrorView builds '
      'then the message text is shown',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          buildSubject(message: 'Sin conexión a internet'),
        );

        expect(find.text('Sin conexión a internet'), findsOneWidget);
      },
    );

    testWidgets(
      'given onRetry is null when ExamplesErrorView builds '
      'then the retry button is not shown',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildSubject(message: 'Error message'));

        expect(find.text('Reintentar'), findsNothing);
      },
    );

    testWidgets(
      'given onRetry is provided when ExamplesErrorView builds '
      'then the retry button is shown',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          buildSubject(message: 'Error message', onRetry: () {}),
        );

        expect(find.text('Reintentar'), findsOneWidget);
      },
    );

    testWidgets(
      'given onRetry is provided when the retry button is tapped '
      'then onRetry is called once',
      (WidgetTester tester) async {
        int callCount = 0;
        await tester.pumpWidget(
          buildSubject(
            message: 'Error message',
            onRetry: () => callCount++,
          ),
        );

        await tester.tap(find.text('Reintentar'));

        expect(callCount, 1);
      },
    );

    testWidgets(
      'given any state when ExamplesErrorView builds '
      'then the error icon is shown',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildSubject(message: 'Error'));

        expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
      },
    );
  });
}
