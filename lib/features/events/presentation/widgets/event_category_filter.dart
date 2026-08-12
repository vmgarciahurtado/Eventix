import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/core/l10n/app_localizations.dart';
import 'package:eventix/features/app_config/domain/entities/filters_config.dart';
import 'package:eventix/features/app_config/presentation/providers/app_config_provider.dart';
import 'package:eventix/features/events/domain/entities/category.dart';
import 'package:eventix/features/events/domain/entities/event_filter.dart';
import 'package:eventix/features/events/presentation/providers/categories_provider.dart';
import 'package:eventix/features/events/presentation/providers/event_filter_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EventCategoryFilter extends ConsumerWidget {
  const EventCategoryFilter({super.key});

  static const double _height = 44;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final EventFilter filter = ref.watch(eventFilterProvider);
    final EventFilterNotifier notifier = ref.read(eventFilterProvider.notifier);
    final AsyncValue<List<Category>> categoriesAsync = ref.watch(
      categoriesProvider,
    );
    final FiltersConfig config = ref.watch(appConfigProvider).filters;

    return SizedBox(
      height: _height,
      child: categoriesAsync.maybeWhen(
        data: (List<Category> remote) => ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: UiSpacing.medium),
          children: <Widget>[
            _CategoryChip(
              label: l10n.filter_all_categories,
              selected: filter.categoryId == null,
              onSelected: () => notifier.setCategory(null),
            ),
            for (final Category c in _arrange(remote, config))
              Padding(
                padding: const EdgeInsets.only(left: UiSpacing.small),
                child: _CategoryChip(
                  label: c.name,
                  selected: filter.categoryId == c.id,
                  onSelected: () => notifier.setCategory(
                    filter.categoryId == c.id ? null : c.id,
                  ),
                ),
              ),
          ],
        ),
        orElse: () => const SizedBox.shrink(),
      ),
    );
  }

  /// Quita las categorías que el JSON oculta y sube las que fija, en el orden
  /// del archivo. El resto conserva el orden del backend.
  List<Category> _arrange(List<Category> remote, FiltersConfig config) {
    final List<Category> rest = <Category>[
      for (final Category c in remote)
        if (!config.hiddenCategories.contains(c.name)) c,
    ];
    final List<Category> pinned = <Category>[];
    for (final String name in config.pinnedCategories) {
      final int index = rest.indexWhere((Category c) => c.name == name);
      if (index != -1) pinned.add(rest.removeAt(index));
    }
    return <Category>[...pinned, ...rest];
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onSelected(),
      ),
    );
  }
}
