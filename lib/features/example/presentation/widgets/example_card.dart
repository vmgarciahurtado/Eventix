import 'package:flutter/material.dart';
import 'package:eventix/core/extensions/theme_extension.dart';
import 'package:eventix/features/example/domain/entities/example.dart';

class ExampleCard extends StatelessWidget {
  const ExampleCard({required this.example, super.key});

  final Example example;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _IdBadge(id: example.id),
            const SizedBox(height: 8),
            Text(example.name, style: context.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              example.description,
              style: context.textTheme.bodySmall,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _IdBadge extends StatelessWidget {
  const _IdBadge({required this.id});

  final int id;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: context.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '#$id',
        style: context.textTheme.labelSmall?.copyWith(
          color: context.colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}
