import 'package:flutter/material.dart';

/// Lockup de marca de Eventix (símbolo + wordmark). Se dimensiona por ancho:
/// es el wordmark el que define a partir de qué tamaño se lee.
class AppLogo extends StatelessWidget {
  const AppLogo({required this.width, super.key});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Image.asset('assets/images/logo.png', width: width);
  }
}
