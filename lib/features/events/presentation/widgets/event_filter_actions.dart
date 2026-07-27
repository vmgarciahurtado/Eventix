import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/core/helpers/date_format.dart';
import 'package:eventix/core/l10n/app_localizations.dart';
import 'package:eventix/features/events/domain/entities/city.dart';
import 'package:eventix/features/events/domain/entities/event_filter.dart';
import 'package:eventix/features/events/presentation/providers/cities_provider.dart';
import 'package:eventix/features/events/presentation/providers/event_filter_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EventFilterActions extends ConsumerWidget {
  const EventFilterActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final EventFilter filter = ref.watch(eventFilterProvider);
    final EventFilterNotifier notifier = ref.read(eventFilterProvider.notifier);
    final AsyncValue<List<City>> citiesAsync = ref.watch(citiesProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: UiSpacing.medium,
        vertical: UiSpacing.small,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.location_city_outlined),
              label: Text(
                _cityLabel(l10n, filter.cityId, citiesAsync.value),
                overflow: TextOverflow.ellipsis,
              ),
              onPressed: citiesAsync.hasValue
                  ? () => _pickCity(context, notifier, citiesAsync.value!)
                  : null,
            ),
          ),
          const SizedBox(width: UiSpacing.small),
          OutlinedButton.icon(
            icon: const Icon(Icons.event_outlined),
            label: Text(
              filter.date == null
                  ? l10n.filter_date
                  : formatEventDay(filter.date!),
            ),
            onPressed: () => _pickDate(context, notifier, filter),
          ),
          if (!filter.isEmpty)
            IconButton(
              tooltip: l10n.filter_clear,
              icon: const Icon(Icons.filter_alt_off_outlined),
              onPressed: notifier.clear,
            ),
        ],
      ),
    );
  }

  String _cityLabel(AppLocalizations l10n, int? cityId, List<City>? cities) {
    for (final City c in cities ?? const <City>[]) {
      if (c.id == cityId) return c.name;
    }
    return l10n.filter_city;
  }

  Future<void> _pickCity(
    BuildContext context,
    EventFilterNotifier notifier,
    List<City> cities,
  ) async {
    final ({int? cityId})? selected =
        await showModalBottomSheet<({int? cityId})>(
          context: context,
          builder: (BuildContext context) => SafeArea(
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                ListTile(
                  title: Text(AppLocalizations.of(context).filter_all_cities),
                  onTap: () => Navigator.of(context).pop((cityId: null)),
                ),
                for (final City c in cities)
                  ListTile(
                    title: Text(c.name),
                    onTap: () => Navigator.of(context).pop((cityId: c.id)),
                  ),
              ],
            ),
          ),
        );
    if (selected == null) return;
    notifier.setCity(selected.cityId);
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
