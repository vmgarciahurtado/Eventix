// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get app_name => 'Eventix';

  @override
  String get action_retry => 'Retry';

  @override
  String get action_refresh => 'Refresh';

  @override
  String get action_reserve => 'Reserve';

  @override
  String get common_sold_out => 'Sold out';

  @override
  String get common_free => 'Free';

  @override
  String get error_unexpected => 'An unexpected error occurred';

  @override
  String get missing_env_message =>
      'The .env file is not configured.\n\nCopy .env.example to .env in the project root and use the values shared through a private channel. Then run the app again.';

  @override
  String get validator_email_empty => 'Enter your email';

  @override
  String get validator_email_invalid => 'Invalid email';

  @override
  String get validator_password_empty => 'Enter your password';

  @override
  String get validator_password_min => 'At least 6 characters';

  @override
  String get validator_first_name_required => 'Enter your first name';

  @override
  String get validator_last_name_required => 'Enter your last name';

  @override
  String get validator_confirm_password_empty => 'Confirm your password';

  @override
  String get validator_confirm_password_mismatch => 'Passwords do not match';

  @override
  String get field_email_label => 'Email';

  @override
  String get field_email_hint => 'you@email.com';

  @override
  String get field_password_label => 'Password';

  @override
  String get field_confirm_password_label => 'Confirm password';

  @override
  String get login_welcome => 'Welcome to Eventix';

  @override
  String get login_subtitle => 'Sign in to discover events';

  @override
  String get login_forgot_password => 'Forgot your password?';

  @override
  String get login_submit => 'Sign in';

  @override
  String get login_no_account => 'Don\'t have an account?';

  @override
  String get login_register_cta => 'Sign up';

  @override
  String get register_title => 'Create account';

  @override
  String get register_terms_required =>
      'You must accept the terms and conditions';

  @override
  String get register_code_sent => 'We sent a code to your email';

  @override
  String get field_first_name_label => 'First name';

  @override
  String get field_last_name_label => 'Last name';

  @override
  String get register_accept_terms_label => 'I accept the';

  @override
  String get register_terms_link => 'terms and conditions';

  @override
  String get register_submit => 'Sign up';

  @override
  String get new_password_title => 'New password';

  @override
  String get new_password_success_title => 'Password updated!';

  @override
  String get new_password_success_message => 'Sign in with your new password.';

  @override
  String get new_password_success_button => 'Go to sign in';

  @override
  String get field_new_password_label => 'New password';

  @override
  String get new_password_submit => 'Save password';

  @override
  String get reset_password_title => 'Recover password';

  @override
  String get reset_password_code_sent => 'We sent you a code to reset it';

  @override
  String get reset_password_description =>
      'Enter your email and we\'ll send you a code to create a new password.';

  @override
  String get reset_password_submit => 'Send code';

  @override
  String get verify_incomplete_code => 'Enter the complete code';

  @override
  String get verify_code_resent => 'Code resent';

  @override
  String get verify_title => 'Verify your email';

  @override
  String verify_sent_to(String email) {
    return 'Enter the code we sent to $email';
  }

  @override
  String get verify_submit => 'Verify';

  @override
  String get verify_resend => 'Resend code';

  @override
  String event_spots_available(int available, int capacity) {
    return '$available of $capacity spots available';
  }

  @override
  String event_spots_short(int capacity) {
    return '$capacity spots';
  }

  @override
  String get event_description_title => 'Description';

  @override
  String get filter_all_categories => 'All';

  @override
  String get filter_city => 'City';

  @override
  String get filter_date => 'Date';

  @override
  String get filter_clear => 'Clear filters';

  @override
  String get filter_all_cities => 'All cities';

  @override
  String get home_logout => 'Sign out';

  @override
  String get home_empty_title => 'No events';

  @override
  String get home_empty_message =>
      'We couldn\'t find events with these filters.';

  @override
  String get reservations_title => 'My reservations';

  @override
  String get reservations_empty_title => 'You don\'t have reservations yet';

  @override
  String get reservations_empty_message =>
      'When you reserve an event it will appear here.';

  @override
  String reservation_quantity(int quantity) {
    return '$quantity spot(s)';
  }

  @override
  String reservation_reserved_on(String date) {
    return 'Reserved on $date';
  }

  @override
  String get onboarding_save_error =>
      'We couldn\'t save your preference: you\'ll see this intro again next time you enter.';

  @override
  String get onboarding_skip => 'Skip';

  @override
  String get onboarding_slide1_title => 'Discover events';

  @override
  String get onboarding_slide1_body =>
      'Explore concerts, fairs and experiences near you.';

  @override
  String get onboarding_slide2_title => 'Filter your way';

  @override
  String get onboarding_slide2_body => 'Find events by category, date or city.';

  @override
  String get onboarding_slide3_title => 'Reserve your spots';

  @override
  String get onboarding_slide3_body =>
      'Set aside your tickets and check your reservations whenever you want.';

  @override
  String get onboarding_start => 'Get started';

  @override
  String get onboarding_next => 'Next';

  @override
  String get checkout_title => 'Secure payment';

  @override
  String get reserve_confirm_pay_title => 'Pay with Stripe';

  @override
  String reserve_confirm_free_message(int quantity, String title) {
    return 'You\'re going to reserve $quantity spot(s) for \"$title\". This event is free. Confirm?';
  }

  @override
  String reserve_confirm_pay_message(
    String amount,
    int quantity,
    String title,
  ) {
    return 'You\'re going to pay $amount for $quantity spot(s) for \"$title\".';
  }

  @override
  String get reserve_success => 'Reservation confirmed!';

  @override
  String get reserve_cancelled => 'Payment cancelled. No reservation was made.';

  @override
  String get reserve_not_paid =>
      'The payment was not completed. No reservation was made.';

  @override
  String get reserve_unconfirmed =>
      'We received your payment but the reservation couldn\'t be confirmed. Write to us to resolve it.';

  @override
  String get reserve_quantity_label => 'Number of spots';

  @override
  String get reserve_unit_price => 'Unit price';

  @override
  String get reserve_total => 'Total';

  @override
  String get reserve_invoice_option => 'Send the invoice to my email';

  @override
  String get reserve_free_button => 'Reserve for free';

  @override
  String reserve_pay_button(String amount) {
    return 'Pay $amount';
  }

  @override
  String get reserve_sold_out_label => 'Event sold out';

  @override
  String get reserve_availability_loading => 'Checking availability…';

  @override
  String reserve_spots_total(int capacity) {
    return '$capacity total spots';
  }
}
