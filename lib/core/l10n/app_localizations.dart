import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @app_name.
  ///
  /// In en, this message translates to:
  /// **'Eventix'**
  String get app_name;

  /// No description provided for @action_retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get action_retry;

  /// No description provided for @action_refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get action_refresh;

  /// No description provided for @action_reserve.
  ///
  /// In en, this message translates to:
  /// **'Reserve'**
  String get action_reserve;

  /// No description provided for @common_sold_out.
  ///
  /// In en, this message translates to:
  /// **'Sold out'**
  String get common_sold_out;

  /// No description provided for @common_free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get common_free;

  /// No description provided for @error_unexpected.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred'**
  String get error_unexpected;

  /// No description provided for @missing_env_message.
  ///
  /// In en, this message translates to:
  /// **'The .env file is not configured.\n\nCopy .env.example to .env in the project root and use the values shared through a private channel. Then run the app again.'**
  String get missing_env_message;

  /// No description provided for @validator_email_empty.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get validator_email_empty;

  /// No description provided for @validator_email_invalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get validator_email_invalid;

  /// No description provided for @validator_password_empty.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get validator_password_empty;

  /// No description provided for @validator_password_min.
  ///
  /// In en, this message translates to:
  /// **'At least 6 characters'**
  String get validator_password_min;

  /// No description provided for @validator_first_name_required.
  ///
  /// In en, this message translates to:
  /// **'Enter your first name'**
  String get validator_first_name_required;

  /// No description provided for @validator_last_name_required.
  ///
  /// In en, this message translates to:
  /// **'Enter your last name'**
  String get validator_last_name_required;

  /// No description provided for @validator_confirm_password_empty.
  ///
  /// In en, this message translates to:
  /// **'Confirm your password'**
  String get validator_confirm_password_empty;

  /// No description provided for @validator_confirm_password_mismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get validator_confirm_password_mismatch;

  /// No description provided for @field_email_label.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get field_email_label;

  /// No description provided for @field_email_hint.
  ///
  /// In en, this message translates to:
  /// **'you@email.com'**
  String get field_email_hint;

  /// No description provided for @field_password_label.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get field_password_label;

  /// No description provided for @field_confirm_password_label.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get field_confirm_password_label;

  /// No description provided for @login_welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Eventix'**
  String get login_welcome;

  /// No description provided for @login_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to discover events'**
  String get login_subtitle;

  /// No description provided for @login_forgot_password.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get login_forgot_password;

  /// No description provided for @login_submit.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get login_submit;

  /// No description provided for @login_no_account.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get login_no_account;

  /// No description provided for @login_register_cta.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get login_register_cta;

  /// No description provided for @register_title.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get register_title;

  /// No description provided for @register_terms_required.
  ///
  /// In en, this message translates to:
  /// **'You must accept the terms and conditions'**
  String get register_terms_required;

  /// No description provided for @register_code_sent.
  ///
  /// In en, this message translates to:
  /// **'We sent a code to your email'**
  String get register_code_sent;

  /// No description provided for @field_first_name_label.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get field_first_name_label;

  /// No description provided for @field_last_name_label.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get field_last_name_label;

  /// No description provided for @register_accept_terms_label.
  ///
  /// In en, this message translates to:
  /// **'I accept the'**
  String get register_accept_terms_label;

  /// No description provided for @register_terms_link.
  ///
  /// In en, this message translates to:
  /// **'terms and conditions'**
  String get register_terms_link;

  /// No description provided for @register_submit.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get register_submit;

  /// No description provided for @new_password_title.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get new_password_title;

  /// No description provided for @new_password_success_title.
  ///
  /// In en, this message translates to:
  /// **'Password updated!'**
  String get new_password_success_title;

  /// No description provided for @new_password_success_message.
  ///
  /// In en, this message translates to:
  /// **'Sign in with your new password.'**
  String get new_password_success_message;

  /// No description provided for @new_password_success_button.
  ///
  /// In en, this message translates to:
  /// **'Go to sign in'**
  String get new_password_success_button;

  /// No description provided for @field_new_password_label.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get field_new_password_label;

  /// No description provided for @new_password_submit.
  ///
  /// In en, this message translates to:
  /// **'Save password'**
  String get new_password_submit;

  /// No description provided for @reset_password_title.
  ///
  /// In en, this message translates to:
  /// **'Recover password'**
  String get reset_password_title;

  /// No description provided for @reset_password_code_sent.
  ///
  /// In en, this message translates to:
  /// **'We sent you a code to reset it'**
  String get reset_password_code_sent;

  /// No description provided for @reset_password_description.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we\'ll send you a code to create a new password.'**
  String get reset_password_description;

  /// No description provided for @reset_password_submit.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get reset_password_submit;

  /// No description provided for @verify_incomplete_code.
  ///
  /// In en, this message translates to:
  /// **'Enter the complete code'**
  String get verify_incomplete_code;

  /// No description provided for @verify_code_resent.
  ///
  /// In en, this message translates to:
  /// **'Code resent'**
  String get verify_code_resent;

  /// No description provided for @verify_title.
  ///
  /// In en, this message translates to:
  /// **'Verify your email'**
  String get verify_title;

  /// No description provided for @verify_sent_to.
  ///
  /// In en, this message translates to:
  /// **'Enter the code we sent to {email}'**
  String verify_sent_to(String email);

  /// No description provided for @verify_submit.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify_submit;

  /// No description provided for @verify_resend.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get verify_resend;

  /// No description provided for @event_spots_available.
  ///
  /// In en, this message translates to:
  /// **'{available} of {capacity} spots available'**
  String event_spots_available(int available, int capacity);

  /// No description provided for @event_spots_short.
  ///
  /// In en, this message translates to:
  /// **'{capacity} spots'**
  String event_spots_short(int capacity);

  /// No description provided for @event_description_title.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get event_description_title;

  /// No description provided for @filter_all_categories.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filter_all_categories;

  /// No description provided for @filter_city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get filter_city;

  /// No description provided for @filter_date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get filter_date;

  /// No description provided for @filter_clear.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get filter_clear;

  /// No description provided for @filter_all_cities.
  ///
  /// In en, this message translates to:
  /// **'All cities'**
  String get filter_all_cities;

  /// No description provided for @home_logout.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get home_logout;

  /// No description provided for @home_empty_title.
  ///
  /// In en, this message translates to:
  /// **'No events'**
  String get home_empty_title;

  /// No description provided for @home_empty_message.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find events with these filters.'**
  String get home_empty_message;

  /// No description provided for @reservations_title.
  ///
  /// In en, this message translates to:
  /// **'My reservations'**
  String get reservations_title;

  /// No description provided for @reservations_empty_title.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have reservations yet'**
  String get reservations_empty_title;

  /// No description provided for @reservations_empty_message.
  ///
  /// In en, this message translates to:
  /// **'When you reserve an event it will appear here.'**
  String get reservations_empty_message;

  /// No description provided for @reservation_quantity.
  ///
  /// In en, this message translates to:
  /// **'{quantity} spot(s)'**
  String reservation_quantity(int quantity);

  /// No description provided for @reservation_reserved_on.
  ///
  /// In en, this message translates to:
  /// **'Reserved on {date}'**
  String reservation_reserved_on(String date);

  /// No description provided for @onboarding_save_error.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t save your preference: you\'ll see this intro again next time you enter.'**
  String get onboarding_save_error;

  /// No description provided for @onboarding_skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboarding_skip;

  /// No description provided for @onboarding_slide1_title.
  ///
  /// In en, this message translates to:
  /// **'Discover events'**
  String get onboarding_slide1_title;

  /// No description provided for @onboarding_slide1_body.
  ///
  /// In en, this message translates to:
  /// **'Explore concerts, fairs and experiences near you.'**
  String get onboarding_slide1_body;

  /// No description provided for @onboarding_slide2_title.
  ///
  /// In en, this message translates to:
  /// **'Filter your way'**
  String get onboarding_slide2_title;

  /// No description provided for @onboarding_slide2_body.
  ///
  /// In en, this message translates to:
  /// **'Find events by category, date or city.'**
  String get onboarding_slide2_body;

  /// No description provided for @onboarding_slide3_title.
  ///
  /// In en, this message translates to:
  /// **'Reserve your spots'**
  String get onboarding_slide3_title;

  /// No description provided for @onboarding_slide3_body.
  ///
  /// In en, this message translates to:
  /// **'Set aside your tickets and check your reservations whenever you want.'**
  String get onboarding_slide3_body;

  /// No description provided for @onboarding_start.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onboarding_start;

  /// No description provided for @onboarding_next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboarding_next;

  /// No description provided for @checkout_title.
  ///
  /// In en, this message translates to:
  /// **'Secure payment'**
  String get checkout_title;

  /// No description provided for @reserve_confirm_pay_title.
  ///
  /// In en, this message translates to:
  /// **'Pay with Stripe'**
  String get reserve_confirm_pay_title;

  /// No description provided for @reserve_confirm_free_message.
  ///
  /// In en, this message translates to:
  /// **'You\'re going to reserve {quantity} spot(s) for \"{title}\". This event is free. Confirm?'**
  String reserve_confirm_free_message(int quantity, String title);

  /// No description provided for @reserve_confirm_pay_message.
  ///
  /// In en, this message translates to:
  /// **'You\'re going to pay {amount} for {quantity} spot(s) for \"{title}\".'**
  String reserve_confirm_pay_message(String amount, int quantity, String title);

  /// No description provided for @reserve_success.
  ///
  /// In en, this message translates to:
  /// **'Reservation confirmed!'**
  String get reserve_success;

  /// No description provided for @reserve_cancelled.
  ///
  /// In en, this message translates to:
  /// **'Payment cancelled. No reservation was made.'**
  String get reserve_cancelled;

  /// No description provided for @reserve_not_paid.
  ///
  /// In en, this message translates to:
  /// **'The payment was not completed. No reservation was made.'**
  String get reserve_not_paid;

  /// No description provided for @reserve_unconfirmed.
  ///
  /// In en, this message translates to:
  /// **'We received your payment but the reservation couldn\'t be confirmed. Write to us to resolve it.'**
  String get reserve_unconfirmed;

  /// No description provided for @reserve_quantity_label.
  ///
  /// In en, this message translates to:
  /// **'Number of spots'**
  String get reserve_quantity_label;

  /// No description provided for @reserve_unit_price.
  ///
  /// In en, this message translates to:
  /// **'Unit price'**
  String get reserve_unit_price;

  /// No description provided for @reserve_total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get reserve_total;

  /// No description provided for @reserve_invoice_option.
  ///
  /// In en, this message translates to:
  /// **'Send the invoice to my email'**
  String get reserve_invoice_option;

  /// No description provided for @reserve_free_button.
  ///
  /// In en, this message translates to:
  /// **'Reserve for free'**
  String get reserve_free_button;

  /// No description provided for @reserve_pay_button.
  ///
  /// In en, this message translates to:
  /// **'Pay {amount}'**
  String reserve_pay_button(String amount);

  /// No description provided for @reserve_sold_out_label.
  ///
  /// In en, this message translates to:
  /// **'Event sold out'**
  String get reserve_sold_out_label;

  /// No description provided for @reserve_availability_loading.
  ///
  /// In en, this message translates to:
  /// **'Checking availability…'**
  String get reserve_availability_loading;

  /// No description provided for @reserve_spots_total.
  ///
  /// In en, this message translates to:
  /// **'{capacity} total spots'**
  String reserve_spots_total(int capacity);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
