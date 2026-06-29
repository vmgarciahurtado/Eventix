/// Validadores reutilizables para formularios (`TextFormField` / `UiTextField`).
///
/// Devuelven `null` cuando el valor es válido, o un mensaje en español cuando
/// no lo es (compatible con `FormFieldValidator<String>`).
abstract final class FormValidators {
  static final RegExp _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? email(String? value) {
    final String v = value?.trim() ?? '';
    if (v.isEmpty) return 'Ingresa tu correo';
    if (!_emailRegex.hasMatch(v)) return 'Correo inválido';
    return null;
  }

  static String? password(String? value) {
    final String v = value ?? '';
    if (v.isEmpty) return 'Ingresa tu contraseña';
    if (v.length < 6) return 'Mínimo 6 caracteres';
    return null;
  }

  static String? required(String? value, [String message = 'Campo requerido']) {
    if ((value?.trim() ?? '').isEmpty) return message;
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if ((value ?? '').isEmpty) return 'Confirma tu contraseña';
    if (value != original) return 'Las contraseñas no coinciden';
    return null;
  }
}
