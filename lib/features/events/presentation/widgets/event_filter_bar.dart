import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/core/helpers/date_format.dart';
import 'package:eventix/features/events/domain/entities/category.dart';
import 'package:eventix/features/events/domain/entities/city.dart';
import 'package:eventix/features/events/domain/entities/event_filter.dart';
import 'package:eventix/features/events/presentation/providers/events_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EventFilterBar extends ConsumerWidget {
  const EventFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final EventFilter filter = ref.watch(eventFilterProvider);
    final EventFilterNotifier notifier = ref.read(eventFilterProvider.notifier);
    final AsyncValue<List<Category>> categoriesAsync = ref.watch(
      categoriesProvider,
    );
    final AsyncValue<List<City>> citiesAsync = ref.watch(citiesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SizedBox(
          height: 44,
          child: categoriesAsync.maybeWhen(
            data: (List<Category> categories) => ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: UiSpacing.md),
              children: <Widget>[
                _CategoryChip(
                  label: 'Todas',
                  selected: filter.categoryId == null,
                  onSelected: () => notifier.setCategory(null),
                ),
                for (final Category c in categories)
                  Padding(
                    padding: const EdgeInsets.only(left: UiSpacing.sm),
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
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            UiSpacing.md,
            UiSpacing.sm,
            UiSpacing.md,
            UiSpacing.sm,
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.location_city_outlined),
                  label: Text(
                    _cityLabel(filter, citiesAsync),
                    overflow: TextOverflow.ellipsis,
                  ),
                  onPressed: citiesAsync.hasValue
                      ? () => _pickCity(
                          context,
                          notifier,
                          citiesAsync.value!,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: UiSpacing.sm),
              OutlinedButton.icon(
                icon: const Icon(Icons.event_outlined),
                label: Text(
                  filter.date == null ? 'Fecha' : formatEventDay(filter.date!),
                ),
                onPressed: () => _pickDate(context, notifier, filter),
              ),
              if (!filter.isEmpty)
                IconButton(
                  tooltip: 'Limpiar filtros',
                  icon: const Icon(Icons.filter_alt_off_outlined),
                  onPressed: notifier.clear,
                ),
            ],
          ),
        ),
      ],
    );
  }

  String _cityLabel(EventFilter filter, AsyncValue<List<City>> citiesAsync) {
    if (filter.cityId == null) return 'Ciudad';
    final List<City>? cities = citiesAsync.value;
    if (cities == null) return 'Ciudad';
    for (final City c in cities) {
      if (c.id == filter.cityId) return c.name;
    }
    return 'Ciudad';
  }

  Future<void> _pickCity(
    BuildContext context,
    EventFilterNotifier notifier,
    List<City> cities,
  ) async {
    final int? selected = await showModalBottomSheet<int?>(
      context: context,
      builder: (BuildContext context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            ListTile(
              title: const Text('Todas las ciudades'),
              onTap: () => Navigator.of(context).pop(-1),
            ),
            for (final City c in cities)
              ListTile(
                title: Text(c.name),
                onTap: () => Navigator.of(context).pop(c.id),
              ),
          ],
        ),
      ),
    );
    if (selected == null) return;
    notifier.setCity(selected == -1 ? null : selected);
  }

  Future<void> _pickDate(
    BuildContext context,
    EventFilterNotifier notifier,
    EventFilter filter,
  ) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: filter.date ?? now,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) notifier.setDate(picked);
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
