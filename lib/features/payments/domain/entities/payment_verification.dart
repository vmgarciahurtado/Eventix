/// Resultado de verificar una sesión de pago en el servidor.
///
/// [reservationConfirmed] puede ser false aun con [paid] true: el pending
/// expiró y el cupo se revendió, caso que la UI debe informar.
class PaymentVerification {
  const PaymentVerification({
    required this.paid,
    required this.reservationConfirmed,
  });

  final bool paid;
  final bool reservationConfirmed;
}
