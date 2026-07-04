sealed class Failure implements Exception {
  const Failure();
  String get userMessage;
}

class ConnectionFailure extends Failure {
  final String message;
  const ConnectionFailure([this.message = 'Sin conexión a internet']);
  @override
  String get userMessage => message;
}

class ServerFailure extends Failure {
  final String message;
  const ServerFailure([
    this.message = 'Error del servidor. Intenta de nuevo más tarde.',
  ]);
  @override
  String get userMessage => message;
}

class NotFoundFailure extends Failure {
  final String message;
  const NotFoundFailure([this.message = 'Recurso no encontrado']);
  @override
  String get userMessage => message;
}

class UnauthorizedFailure extends Failure {
  final String message;
  const UnauthorizedFailure([this.message = 'Sesión expirada']);
  @override
  String get userMessage => message;
}

/// Error de autenticación con mensaje amigable (credenciales, OTP, etc.).
class AuthFailure extends Failure {
  final String message;
  const AuthFailure([this.message = 'No fue posible completar la operación']);
  @override
  String get userMessage => message;
}

/// Error de validación de datos enviados (entrada inválida, conflicto, etc.).
class ValidationFailure extends Failure {
  final String message;
  const ValidationFailure([this.message = 'Datos inválidos']);
  @override
  String get userMessage => message;
}

class UnexpectedFailure extends Failure {
  /// Detalle técnico para logs/debug; NUNCA se muestra al usuario.
  final String message;
  const UnexpectedFailure([this.message = 'Error inesperado']);
  @override
  String get userMessage => 'Algo salió mal. Intenta de nuevo.';
}
