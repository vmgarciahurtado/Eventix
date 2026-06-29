import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:flutter/material.dart';

/// Logo de Eventix. Usa `assets/images/logo.png` si existe; si no, cae a un
/// ícono del tema (para que la app funcione sin el asset).
class AppLogo extends StatelessWidget {
  const AppLogo({this.size = 80, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo.png',
      height: size,
      errorBuilder: (BuildContext _, Object __, StackTrace? ___) => Icon(
        Icons.confirmation_num_rounded,
        size: size,
        color: context.colorScheme.primary,
      ),
    );
  }
}
