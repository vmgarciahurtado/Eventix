import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/core/helpers/date_format.dart';
import 'package:eventix/core/helpers/money_format.dart';
import 'package:eventix/features/events/domain/entities/event.dart';
import 'package:eventix/features/events/presentation/widgets/category_visuals.dart';
import 'package:flutter/material.dart';

class EventCard extends StatelessWidget {
  const EventCard({required this.event, required this.onTap, super.key});

  final Event event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final CategoryVisual visual = categoryVisual(event.categoryName);
    return Card(
      margin: const EdgeInsets.only(bottom: UiSpacing.md),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _Header(event: event, visual: visual),
            Padding(
              padding: const EdgeInsets.all(UiSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    event.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: UiSpacing.xs),
                  _IconText(
                    icon: Icons.location_on_outlined,
                    text: event.cityName,
                  ),
                  const SizedBox(height: UiSpacing.xxs),
                  _IconText(
                    icon: Icons.calendar_today_outlined,
                    text: formatEventDateTime(event.startsAt),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.event, required this.visual});

  final Event event;
  final CategoryVisual visual;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: visual.colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: <Widget>[
            Center(
              child: Icon(visual.icon, size: 56, color: Colors.white),
            ),
            Positioned(
              top: UiSpacing.sm,
              left: UiSpacing.sm,
              child: _Pill(text: event.categoryName),
            ),
            Positioned(
              top: UiSpacing.sm,
              right: UiSpacing.sm,
              child: _Pill(text: formatPrice(event.price)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: UiSpacing.sm,
        vertical: UiSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: UiRadius.borderFull,
      ),
      child: Text(
        text,
        style: context.textTheme.labelSmall?.copyWith(color: Colors.white),
      ),
    );
  }
}

class _IconText extends StatelessWidget {
  const _IconText({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon, size: 16, color: context.colorScheme.onSurfaceVariant),
        const SizedBox(width: UiSpacing.xs),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
