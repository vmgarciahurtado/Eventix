import 'package:flutter/material.dart';
import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/core/extensions/responsive_extension.dart';
import 'package:eventix/core/extensions/theme_extension.dart';
import 'package:eventix/features/example/domain/entities/example.dart';
import 'package:eventix/features/example/presentation/providers/examples_provider.dart';
import 'package:eventix/features/example/presentation/widgets/example_card.dart';
import 'package:eventix/features/example/presentation/widgets/examples_error_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExamplesPage extends ConsumerWidget {
  static const String routePath = '/examples';

  const ExamplesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Example>> asyncExamples =
        ref.watch(examplesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Examples', style: context.textTheme.titleLarge),
      ),
      body: asyncExamples.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace _) => ExamplesErrorView(
          message:
              error is Failure ? error.userMessage : 'Error inesperado',
          onRetry: () => ref.invalidate(examplesProvider),
        ),
        data: (List<Example> examples) => _ExamplesList(
          examples: examples,
          onRefresh: () => ref.refresh(examplesProvider.future),
        ),
      ),
    );
  }
}

class _ExamplesList extends StatelessWidget {
  const _ExamplesList({
    required this.examples,
    required this.onRefresh,
  });

  final List<Example> examples;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    if (examples.isEmpty) {
      return Center(
        child: Text('No hay ejemplos', style: context.textTheme.bodyMedium),
      );
    }

    final int columns = context.responsiveValue<int>(
      desktop: 3,
      tablet: 2,
      mobile: 1,
    );

    if (columns == 1) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: examples.length,
          separatorBuilder: (BuildContext _, int __) =>
              const SizedBox(height: 8),
          itemBuilder: (BuildContext _, int i) =>
              ExampleCard(example: examples[i]),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.4,
      ),
      itemCount: examples.length,
      itemBuilder: (BuildContext _, int i) =>
          ExampleCard(example: examples[i]),
    );
  }
}
