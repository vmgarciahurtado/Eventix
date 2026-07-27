/// Resultado de verificar el pago al volver del checkout.
enum PaymentCompletion {
  /// Pago verificado y reserva confirmada por el servidor.
  confirmed,

  /// La pasarela no registró el pago (abandonó o falló el cobro).
  notPaid,

  /// Pago registrado pero la reserva no pudo confirmarse (p. ej. el pending
  /// expiró y el cupo se revendió). Requiere intervención/soporte.
  paidButNotConfirmed,
}
