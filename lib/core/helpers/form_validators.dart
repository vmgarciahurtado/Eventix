import 'package:flutter/widgets.dart';

/// Validadores reutilizables para formularios (`TextFormField` / `UiTextField`).
///
/// Cada método construye un [FormFieldValidator] y recibe los mensajes ya
/// localizados: así el helper no depende de `AppLocalizations` y los textos se
/// resuelven en la capa de presentación.
abstract final class FormValidators {
  static final RegExp _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static FormFieldValidator<String> email({
    required String emptyMsg,
    required String invalidMsg,
  }) {
    return (String? value) {
      final String v = value?.trim() ?? '';
      if (v.isEmpty) return emptyMsg;
      if (!_emailRegex.hasMatch(v)) return invalidMsg;
      return null;
    };
  }

  static FormFieldValidator<String> password({
    required String emptyMsg,
    required String minMsg,
  }) {
    return (String? value) {
      final String v = value ?? '';
      if (v.isEmpty) return emptyMsg;
      if (v.length < 6) return minMsg;
      return null;
    };
  }

  static FormFieldValidator<String> required({required String message}) {
    return (String? value) {
      if ((value?.trim() ?? '').isEmpty) return message;
      return null;
    };
  }

  static FormFieldValidator<String> confirmPassword(
    String Function() original, {
    required String emptyMsg,
    required String mismatchMsg,
  }) {
    return (String? value) {
      if ((value ?? '').isEmpty) return emptyMsg;
      if (value != original()) return mismatchMsg;
      return null;
    };
  }
}
