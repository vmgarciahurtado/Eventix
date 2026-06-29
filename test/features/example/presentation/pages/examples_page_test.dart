import 'dart:async';

import 'package:flutter/material.dart';
import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/features/example/domain/entities/example.dart';
import 'package:eventix/features/example/presentation/pages/examples_page.dart';
import 'package:eventix/features/example/presentation/providers/examples_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/src/framework.dart';

// Injects a pre-defined AsyncValue into the provider:
//
// AsyncData  → build() returns the list synchronously.
// AsyncError → build() throws the error; Riverpod sets AsyncError state.
// AsyncLoading → build() returns a never-completing future so the provider
//                stays in loading until the ProviderScope is disposed.
class _FakeExamplesNotifier extends ExamplesNotifier {
  _FakeExamplesNotifier(this._state);

  final AsyncValue<List<Example>> _state;

  @override
  Future<List<Example>> build() async {
    if (_state case AsyncError<List<Example>>(:final Object error)) {
      throw error;
    }
    if (_state case AsyncLoading<List<Example>>()) {
      return Completer<List<Example>>().future;
    }
    return _state.value ?? <Example>[];
  }
}

void main() {
  Widget buildSubject({required AsyncValue<List<Example>> state}) {
    return ProviderScope(
      overrides: <Override>[
        examplesProvider.overrideWith(() => _FakeExamplesNotifier(state)),
      ],
      child: const MaterialApp(home: ExamplesPage()),
    );
  }

  group('ExamplesPage', () {
    testWidgets(
      'given state is AsyncLoading when page builds '
      'then shows CircularProgressIndicator',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          buildSubject(state: const AsyncLoading<List<Example>>()),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );

    testWidgets(
      'given state is AsyncData with examples when page builds '
      'then shows example name and id badge',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          buildSubject(
            state: AsyncData<List<Example>>(<Example>[_tExample()]),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Test Example'), findsOneWidget);
        expect(find.text('#1'), findsOneWidget);
      },
    );

    testWidgets(
      'given state is AsyncData with an empty list when page builds '
      'then shows empty state message',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          buildSubject(
            state: const AsyncData<List<Example>>(<Example>[]),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('No hay ejemplos'), findsOneWidget);
      },
    );

    testWidgets(
      'given state is AsyncError with a Failure when page builds '
      'then shows the failure userMessage',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          buildSubject(
            state: const AsyncError<List<Example>>(
              ConnectionFailure(),
              StackTrace.empty,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Sin conexión a internet'), findsOneWidget);
      },
    );

    testWidgets(
      'given state is AsyncError when page builds '
      'then shows the retry button',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          buildSubject(
            state: const AsyncError<List<Example>>(
              ConnectionFailure(),
              StackTrace.empty,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Reintentar'), findsOneWidget);
      },
    );

    testWidgets(
      'given any state when page builds '
      'then shows the AppBar with title Examples',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          buildSubject(state: const AsyncLoading<List<Example>>()),
        );

        expect(find.text('Examples'), findsOneWidget);
      },
    );
  });
}

Example _tExample() => const Example(
  id: 1,
  name: 'Test Example',
  description: 'Test description',
);
