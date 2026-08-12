import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:flutter/material.dart';

class OnboardingDots extends StatelessWidget {
  const OnboardingDots({required this.count, required this.index, super.key});

  static const double _dotSize = UiSizes.size8;
  static const double _activeWidth = UiSizes.size24;
  static const Duration _animation = Duration(milliseconds: 250);

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(count, (int i) {
        final bool active = i == index;
        return AnimatedContainer(
          duration: _animation,
          margin: const EdgeInsets.symmetric(horizontal: UiSpacing.extraSmall),
          width: active ? _activeWidth : _dotSize,
          height: _dotSize,
          decoration: BoxDecoration(
            color: active
                ? context.colorScheme.primary
                : context.colorScheme.outlineVariant,
            borderRadius: UiRadius.borderFull,
          ),
        );
      }),
    );
  }
}
