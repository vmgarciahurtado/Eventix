import 'package:integration_test/integration_test.dart';

import 'event_detail/event_detail_test.dart' as event_detail;
import 'events/events_test.dart' as events;
import 'exports.dart';
import 'login/login_test.dart' as login;
import 'my_reservations/my_reservations_test.dart' as my_reservations;
import 'onboarding/onboarding_test.dart' as onboarding;
import 'reserve/reserve_test.dart' as reserve;
import 'splash/splash_test.dart' as splash;

/// Punto de entrada de la suite de integración.
///
/// El orden importa: los archivos comparten el `appRouter` y la sesión de
/// Supabase, así que cada uno arranca donde lo dejó el anterior. La secuencia
/// es la del usuario: arranca la app, entra, explora, reserva y revisa.
///
/// ```bash
/// flutter test integration_test/main_test.dart \
///   --dart-define=EVENTIX_TEST_EMAIL=... \
///   --dart-define=EVENTIX_TEST_PASSWORD=...
/// ```
///
/// Para correr un solo tramo, se apunta al archivo directamente: el
/// `bootstrapApp` es idempotente y `setUpAll` lo vuelve a llamar sin efecto.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(bootstrapApp);

  group('end-to-end test:', () {
    splash.main();
    login.main();
    onboarding.main();
    events.main();
    event_detail.main();
    reserve.main();
    my_reservations.main();
  });
}
