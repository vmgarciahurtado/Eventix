/// Sesión de pago hospedada, creada en el servidor.
class CheckoutSession {
  const CheckoutSession({
    required this.url,
    required this.sessionId,
    required this.returnUrlMarker,
  });

  /// URL del checkout que se abre en el WebView.
  final String url;

  /// Identificador con el que luego se verifica el pago.
  final String sessionId;

  /// Cuando el WebView navega a una URL que lo contiene, el flujo terminó y
  /// el resultado viene en el query param `status`. Lo define la pasarela,
  /// así la UI no necesita saber cuál es.
  final String returnUrlMarker;
}
