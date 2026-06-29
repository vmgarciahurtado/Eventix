import 'package:flutter/material.dart';

/// Atajo para mostrar mensajes breves (errores/avisos) desde cualquier widget.
extension SnackX on BuildContext {
  void showSnack(String message) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
