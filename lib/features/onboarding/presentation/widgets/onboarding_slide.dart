import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:flutter/material.dart';

class OnboardingSlide extends StatelessWidget {
  const OnboardingSlide({
    required this.icon,
    required this.title,
    required this.body,
    super.key,
  });

  /// Ilustración: más grande que cualquier token de ícono del kit.
  static const double _iconSize = 120;

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(UiSpacing.extraLarge),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(icon, size: _iconSize, color: context.colorScheme.primary),
          const SizedBox(height: UiSpacing.extraLarge),
          Text(
            title,
            textAlign: TextAlign.center,
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: UiSpacing.small),
          Text(
            body,
            textAlign: TextAlign.center,
            style: context.textTheme.bodyLarge?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
