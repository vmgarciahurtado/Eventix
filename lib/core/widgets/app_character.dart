import 'package:flutter/material.dart';

/// La mascota de Eventix. Si el asset falta no rompe la pantalla: se encoge a
/// nada y el resto del contenido sigue en su sitio.
class AppCharacter extends StatelessWidget {
  const AppCharacter({required this.height, super.key});

  static const String _asset = 'assets/images/character_without_background.png';

  final double height;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      _asset,
      height: height,
      fit: BoxFit.contain,
      errorBuilder: (BuildContext _, Object __, StackTrace? ___) =>
          SizedBox(height: height),
    );
  }
}
