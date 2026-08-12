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
  static const double _iconSize = UiSizes.size120;

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
          UiText(
            title,
            style: UiTextStyle.headline,
            align: TextAlign.center,
            weight: FontWeight.bold,
          ),
          const SizedBox(height: UiSpacing.small),
          UiText(
            body,
            align: TextAlign.center,
            color: context.colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}
