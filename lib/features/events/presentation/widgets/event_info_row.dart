import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:flutter/material.dart';

class EventInfoRow extends StatelessWidget {
  const EventInfoRow({required this.icon, required this.text, super.key});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon, size: 20, color: context.colorScheme.primary),
        const SizedBox(width: UiSpacing.small),
        Expanded(child: Text(text, style: context.textTheme.bodyLarge)),
      ],
    );
  }
}
