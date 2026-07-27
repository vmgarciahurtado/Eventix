/// Resultado del checkout hospedado que corre en el WebView.
enum CheckoutResult {
  success,
  cancel;

  /// Traduce el query param `status` del return_url. Ante un valor
  /// desconocido se asume cancelación (nunca se confirma un pago sin
  /// verificarlo en el servidor de todos modos).
  static CheckoutResult fromStatus(String? status) =>
      status == 'success' ? CheckoutResult.success : CheckoutResult.cancel;
}
