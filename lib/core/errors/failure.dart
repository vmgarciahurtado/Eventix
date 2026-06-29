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

class UnexpectedFailure extends Failure {
  final String message;
  const UnexpectedFailure([this.message = 'Error inesperado']);
  @override
  String get userMessage => message;
}
