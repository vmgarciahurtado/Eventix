/// Sesión de Stripe Checkout creada en el servidor: URL de pago hospedada y
/// el id de sesión para verificar el resultado luego.
class CheckoutSession {
  const CheckoutSession({required this.url, required this.sessionId});

  final String url;
  final String sessionId;
}
