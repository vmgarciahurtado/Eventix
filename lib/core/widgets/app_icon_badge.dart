import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:flutter/material.dart';

/// El icono de la app como chip de marca: identifica la pantalla sin robarle
/// el protagonismo a lo que sí importa en ella.
class AppIconBadge extends StatelessWidget {
  const AppIconBadge({required this.size, super.key});

  final double size;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: UiRadius.borderLarge,
    child: Image.asset(
      'assets/images/app_icon.png',
      width: size,
      height: size,
    ),
  );
}
