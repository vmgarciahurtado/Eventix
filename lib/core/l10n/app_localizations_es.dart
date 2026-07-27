// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get app_name => 'Eventix';

  @override
  String get action_retry => 'Reintentar';

  @override
  String get action_refresh => 'Actualizar';

  @override
  String get action_reserve => 'Reservar';

  @override
  String get common_sold_out => 'Agotado';

  @override
  String get common_free => 'Gratis';

  @override
  String get error_unexpected => 'Ocurrió un error inesperado';

  @override
  String get missing_env_message =>
      'Falta configurar el archivo .env.\n\nCopia .env.example como .env en la raíz del proyecto y usa los valores compartidos por canal privado. Luego vuelve a ejecutar la app.';

  @override
  String get validator_email_empty => 'Ingresa tu correo';

  @override
  String get validator_email_invalid => 'Correo inválido';

  @override
  String get validator_password_empty => 'Ingresa tu contraseña';

  @override
  String get validator_password_min => 'Mínimo 6 caracteres';

  @override
  String get validator_first_name_required => 'Ingresa tu nombre';

  @override
  String get validator_last_name_required => 'Ingresa tu apellido';

  @override
  String get validator_confirm_password_empty => 'Confirma tu contraseña';

  @override
  String get validator_confirm_password_mismatch =>
      'Las contraseñas no coinciden';

  @override
  String get field_email_label => 'Correo';

  @override
  String get field_email_hint => 'tu@correo.com';

  @override
  String get field_password_label => 'Contraseña';

  @override
  String get field_confirm_password_label => 'Confirmar contraseña';

  @override
  String get login_welcome => 'Bienvenido a Eventix';

  @override
  String get login_subtitle => 'Inicia sesión para descubrir eventos';

  @override
  String get login_forgot_password => '¿Olvidaste tu contraseña?';

  @override
  String get login_submit => 'Iniciar sesión';

  @override
  String get login_no_account => '¿No tienes cuenta?';

  @override
  String get login_register_cta => 'Regístrate';

  @override
  String get register_title => 'Crear cuenta';

  @override
  String get register_terms_required =>
      'Debes aceptar los términos y condiciones';

  @override
  String get register_code_sent => 'Te enviamos un código a tu correo';

  @override
  String get field_first_name_label => 'Nombre';

  @override
  String get field_last_name_label => 'Apellido';

  @override
  String get register_accept_terms_label => 'Acepto los';

  @override
  String get register_terms_link => 'términos y condiciones';

  @override
  String get register_submit => 'Registrarme';

  @override
  String get new_password_title => 'Nueva contraseña';

  @override
  String get new_password_success_title => '¡Contraseña actualizada!';

  @override
  String get new_password_success_message =>
      'Inicia sesión con tu nueva contraseña.';

  @override
  String get new_password_success_button => 'Ir a iniciar sesión';

  @override
  String get field_new_password_label => 'Nueva contraseña';

  @override
  String get new_password_submit => 'Guardar contraseña';

  @override
  String get reset_password_title => 'Recuperar contraseña';

  @override
  String get reset_password_code_sent =>
      'Te enviamos un código para restablecer';

  @override
  String get reset_password_description =>
      'Ingresa tu correo y te enviaremos un código para crear una nueva contraseña.';

  @override
  String get reset_password_submit => 'Enviar código';

  @override
  String get verify_incomplete_code => 'Ingresa el código completo';

  @override
  String get verify_code_resent => 'Código reenviado';

  @override
  String get verify_title => 'Verifica tu correo';

  @override
  String verify_sent_to(String email) {
    return 'Escribe el código que enviamos a $email';
  }

  @override
  String get verify_submit => 'Verificar';

  @override
  String get verify_resend => 'Reenviar código';

  @override
  String event_spots_available(int available, int capacity) {
    return '$available de $capacity cupos disponibles';
  }

  @override
  String event_spots_short(int capacity) {
    return '$capacity cupos';
  }

  @override
  String get event_description_title => 'Descripción';

  @override
  String get filter_all_categories => 'Todas';

  @override
  String get filter_city => 'Ciudad';

  @override
  String get filter_date => 'Fecha';

  @override
  String get filter_clear => 'Limpiar filtros';

  @override
  String get filter_all_cities => 'Todas las ciudades';

  @override
  String get home_logout => 'Cerrar sesión';

  @override
  String get home_empty_title => 'Sin eventos';

  @override
  String get home_empty_message => 'No encontramos eventos con estos filtros.';

  @override
  String get reservations_title => 'Mis reservas';

  @override
  String get reservations_empty_title => 'Aún no tienes reservas';

  @override
  String get reservations_empty_message =>
      'Cuando reserves un evento aparecerá aquí.';

  @override
  String reservation_quantity(int quantity) {
    return '$quantity cupo(s)';
  }

  @override
  String reservation_reserved_on(String date) {
    return 'Reservado el $date';
  }

  @override
  String get onboarding_save_error =>
      'No pudimos guardar tu preferencia: verás esta introducción de nuevo al volver a entrar.';

  @override
  String get onboarding_skip => 'Saltar';

  @override
  String get onboarding_slide1_title => 'Descubre eventos';

  @override
  String get onboarding_slide1_body =>
      'Explora conciertos, ferias y experiencias cerca de ti.';

  @override
  String get onboarding_slide2_title => 'Filtra a tu medida';

  @override
  String get onboarding_slide2_body =>
      'Encuentra eventos por categoría, fecha o ciudad.';

  @override
  String get onboarding_slide3_title => 'Reserva tus cupos';

  @override
  String get onboarding_slide3_body =>
      'Aparta tus entradas y revisa tus reservas cuando quieras.';

  @override
  String get onboarding_start => 'Comenzar';

  @override
  String get onboarding_next => 'Siguiente';

  @override
  String get checkout_title => 'Pago seguro';

  @override
  String get reserve_confirm_pay_title => 'Pagar con Stripe';

  @override
  String reserve_confirm_free_message(int quantity, String title) {
    return 'Vas a reservar $quantity cupo(s) para \"$title\". Este evento es gratuito. ¿Confirmar?';
  }

  @override
  String reserve_confirm_pay_message(
    String amount,
    int quantity,
    String title,
  ) {
    return 'Vas a pagar $amount por $quantity cupo(s) para \"$title\".';
  }

  @override
  String get reserve_success => '¡Reserva confirmada!';

  @override
  String get reserve_cancelled => 'Pago cancelado. No se realizó la reserva.';

  @override
  String get reserve_not_paid =>
      'El pago no se completó. No se realizó la reserva.';

  @override
  String get reserve_unconfirmed =>
      'Recibimos tu pago pero la reserva no pudo confirmarse. Escríbenos para resolverlo.';

  @override
  String get reserve_quantity_label => 'Cantidad de cupos';

  @override
  String get reserve_unit_price => 'Precio unitario';

  @override
  String get reserve_total => 'Total';

  @override
  String get reserve_invoice_option => 'Enviar la factura a mi correo';

  @override
  String get reserve_free_button => 'Reservar gratis';

  @override
  String reserve_pay_button(String amount) {
    return 'Pagar $amount';
  }

  @override
  String get reserve_sold_out_label => 'Evento agotado';

  @override
  String get reserve_availability_loading => 'Consultando disponibilidad…';

  @override
  String reserve_spots_total(int capacity) {
    return '$capacity cupos en total';
  }
}
