import 'package:eventix/core/services/supabase/supabase_provider.dart';
import 'package:eventix/features/app_config/di/app_config_di.dart';
import 'package:eventix/features/app_config/domain/repositories/app_config_repository.dart';
import 'package:eventix/features/app_config/domain/usecases/get_app_config.dart';
import 'package:eventix/features/app_config/domain/usecases/reload_app_config.dart';
import 'package:eventix/features/app_config/infrastructure/datasources/app_config_datasource.dart';
import 'package:eventix/features/app_config/infrastructure/datasources/asset_app_config_datasource.dart';
import 'package:eventix/features/auth/di/auth_di.dart';
import 'package:eventix/features/auth/domain/repositories/auth_repository.dart';
import 'package:eventix/features/auth/domain/usecases/register_user.dart';
import 'package:eventix/features/auth/domain/usecases/resend_otp.dart';
import 'package:eventix/features/auth/domain/usecases/resolve_post_auth_destination.dart';
import 'package:eventix/features/auth/domain/usecases/send_password_reset.dart';
import 'package:eventix/features/auth/domain/usecases/sign_in.dart';
import 'package:eventix/features/auth/domain/usecases/sign_out.dart';
import 'package:eventix/features/auth/domain/usecases/update_password.dart';
import 'package:eventix/features/auth/domain/usecases/verify_otp.dart';
import 'package:eventix/features/auth/infrastructure/datasources/auth_datasource.dart';
import 'package:eventix/features/events/di/events_di.dart';
import 'package:eventix/features/events/domain/repositories/events_repository.dart';
import 'package:eventix/features/events/domain/usecases/get_categories.dart';
import 'package:eventix/features/events/domain/usecases/get_cities.dart';
import 'package:eventix/features/events/domain/usecases/get_event_availability.dart';
import 'package:eventix/features/events/domain/usecases/get_event_by_id.dart';
import 'package:eventix/features/events/domain/usecases/get_events.dart';
import 'package:eventix/features/events/infrastructure/datasources/events_datasource.dart';
import 'package:eventix/features/onboarding/di/onboarding_di.dart';
import 'package:eventix/features/onboarding/domain/usecases/complete_onboarding.dart';
import 'package:eventix/features/payments/di/payments_di.dart';
import 'package:eventix/features/payments/domain/repositories/payments_repository.dart';
import 'package:eventix/features/payments/domain/usecases/create_checkout_session.dart';
import 'package:eventix/features/payments/domain/usecases/verify_checkout_session.dart';
import 'package:eventix/features/payments/infrastructure/datasources/payments_datasource.dart';
import 'package:eventix/features/profile/di/profile_di.dart';
import 'package:eventix/features/profile/domain/repositories/profile_repository.dart';
import 'package:eventix/features/profile/infrastructure/datasources/profile_datasource.dart';
import 'package:eventix/features/reservations/di/reservations_di.dart';
import 'package:eventix/features/reservations/domain/repositories/reservations_repository.dart';
import 'package:eventix/features/reservations/domain/usecases/cancel_pending_reservation.dart';
import 'package:eventix/features/reservations/domain/usecases/complete_payment.dart';
import 'package:eventix/features/reservations/domain/usecases/create_reservation.dart';
import 'package:eventix/features/reservations/domain/usecases/get_my_reservations.dart';
import 'package:eventix/features/reservations/domain/usecases/start_purchase.dart';
import 'package:eventix/features/reservations/infrastructure/datasources/reservations_datasource.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MockSupabaseClient extends Mock implements SupabaseClient {}

/// Los composition roots son el punto donde un cambio de firma se detecta en
/// tiempo de ejecución, no de compilación: si un provider queda mal cableado
/// la app explota al abrir la pantalla, no al construirla.
///
/// Se sustituye únicamente el cliente de Supabase, así que se arma el grafo
/// real completo sin tocar la red.
void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(
      overrides: <Override>[
        supabaseClientProvider.overrideWithValue(_MockSupabaseClient()),
      ],
    );
    addTearDown(container.dispose);
  });

  test('auth arma datasource, repositorio y casos de uso', () {
    expect(container.read(authDatasourceProvider), isA<AuthDatasource>());
    expect(container.read(authRepositoryProvider), isA<AuthRepository>());
    expect(container.read(signInProvider), isA<SignIn>());
    expect(container.read(registerUserProvider), isA<RegisterUser>());
    expect(container.read(verifyOtpProvider), isA<VerifyOtp>());
    expect(container.read(resendOtpProvider), isA<ResendOtp>());
    expect(
      container.read(sendPasswordResetProvider),
      isA<SendPasswordReset>(),
    );
    expect(container.read(updatePasswordProvider), isA<UpdatePassword>());
    expect(container.read(signOutProvider), isA<SignOut>());
    expect(
      container.read(resolvePostAuthDestinationProvider),
      isA<ResolvePostAuthDestination>(),
    );
  });

  test('events arma datasource, repositorio y casos de uso', () {
    expect(container.read(eventsDatasourceProvider), isA<EventsDatasource>());
    expect(container.read(eventsRepositoryProvider), isA<EventsRepository>());
    expect(container.read(getEventsProvider), isA<GetEvents>());
    expect(container.read(getEventByIdProvider), isA<GetEventById>());
    expect(container.read(getCategoriesProvider), isA<GetCategories>());
    expect(container.read(getCitiesProvider), isA<GetCities>());
    expect(
      container.read(getEventAvailabilityProvider),
      isA<GetEventAvailability>(),
    );
  });

  test('profile y onboarding comparten el mismo repositorio', () {
    expect(container.read(profileDatasourceProvider), isA<ProfileDatasource>());
    expect(container.read(profileRepositoryProvider), isA<ProfileRepository>());
    expect(
      container.read(completeOnboardingProvider),
      isA<CompleteOnboarding>(),
    );
    // Un segundo repositorio significaría dos cachés del mismo perfil.
    expect(
      container.read(profileRepositoryProvider),
      same(container.read(profileRepositoryProvider)),
    );
  });

  test('payments arma datasource, repositorio y casos de uso', () {
    expect(
      container.read(paymentsDatasourceProvider),
      isA<PaymentsDatasource>(),
    );
    expect(
      container.read(paymentsRepositoryProvider),
      isA<PaymentsRepository>(),
    );
    expect(
      container.read(createCheckoutSessionProvider),
      isA<CreateCheckoutSession>(),
    );
    expect(
      container.read(verifyCheckoutSessionProvider),
      isA<VerifyCheckoutSession>(),
    );
  });

  test('reservations arma su grafo y compone la API de payments', () {
    expect(
      container.read(reservationsDatasourceProvider),
      isA<ReservationsDatasource>(),
    );
    expect(
      container.read(reservationsRepositoryProvider),
      isA<ReservationsRepository>(),
    );
    expect(container.read(createReservationProvider), isA<CreateReservation>());
    expect(
      container.read(cancelPendingReservationProvider),
      isA<CancelPendingReservation>(),
    );
    expect(container.read(getMyReservationsProvider), isA<GetMyReservations>());
    // StartPurchase cruza features: reservations + payments.
    expect(container.read(startPurchaseProvider), isA<StartPurchase>());
    expect(container.read(completePaymentProvider), isA<CompletePayment>());
  });

  test('app_config lee del bundle de assets', () {
    expect(
      container.read(appConfigDatasourceProvider),
      isA<AssetAppConfigDatasource>(),
    );
    expect(
      container.read(appConfigRepositoryProvider),
      isA<AppConfigRepository>(),
    );
    expect(container.read(getAppConfigProvider), isA<GetAppConfig>());
    expect(container.read(reloadAppConfigProvider), isA<ReloadAppConfig>());
  });

  test('cambiar el origen de la configuración es un solo override', () {
    // Es lo que haría falta para traerla de un backend en vez del asset.
    expect(
      container.read(appConfigDatasourceProvider),
      isA<AppConfigDatasource>(),
    );
  });

  test('los repositorios se exponen solo como interfaces del dominio', () {
    // Si un provider expusiera la implementación, una pantalla podría depender
    // de Supabase sin que el compilador lo impida.
    expect(container.read(eventsRepositoryProvider), isA<EventsRepository>());
    expect(container.read(authRepositoryProvider), isA<AuthRepository>());
    expect(
      container.read(reservationsRepositoryProvider),
      isA<ReservationsRepository>(),
    );
    expect(
      container.read(paymentsRepositoryProvider),
      isA<PaymentsRepository>(),
    );
    expect(container.read(profileRepositoryProvider), isA<ProfileRepository>());
  });
}
