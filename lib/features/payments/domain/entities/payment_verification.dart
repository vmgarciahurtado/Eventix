/// Resultado de verificar una sesión de pago en el servidor.
///
/// [paid] indica si Stripe registró el pago; [reservationConfirmed] si la
/// Edge Function logró confirmar la reserva asociada (puede ser false si el
/// pending expiró y el cupo se revendió — caso que la UI debe informar).
class PaymentVerification {
  const PaymentVerification({
    required this.paid,
    required this.reservationConfirmed,
  });

  final bool paid;
  final bool reservationConfirmed;

  @override
  bool operator ==(Object other) =>
      other is PaymentVerification &&
      other.paid == paid &&
      other.reservationConfirmed == reservationConfirmed;

  @override
  int get hashCode => Object.hash(paid, reservationConfirmed);
}
