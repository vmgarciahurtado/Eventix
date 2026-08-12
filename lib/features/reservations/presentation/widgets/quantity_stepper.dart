import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:flutter/material.dart';

/// Selector de cantidad acotado a `[1, max]`. Con [onChanged] nulo queda
/// deshabilitado por completo.
class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    required this.value,
    required this.max,
    required this.onChanged,
    super.key,
  });

  final int value;
  final int max;
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    final ValueChanged<int>? onChanged = this.onChanged;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        IconButton.filledTonal(
          icon: const Icon(Icons.remove),
          onPressed: (onChanged == null || value <= 1)
              ? null
              : () => onChanged(value - 1),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: UiSpacing.medium),
          child: UiText('$value', style: UiTextStyle.title),
        ),
        IconButton.filledTonal(
          icon: const Icon(Icons.add),
          onPressed: (onChanged == null || value >= max)
              ? null
              : () => onChanged(value + 1),
        ),
      ],
    );
  }
}
