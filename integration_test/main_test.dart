import 'package:integration_test/integration_test.dart';

import 'event_detail/event_detail_test.dart' as event_detail;
import 'events/events_test.dart' as events;
import 'exports.dart';
import 'login/login_test.dart' as login;
import 'my_reservations/my_reservations_test.dart' as my_reservations;
import 'onboarding/onboarding_test.dart' as onboarding;
import 'reserve/reserve_test.dart' as reserve;
import 'splash/splash_test.dart' as splash;

/// Punto de entrada de la suite. El orden es el del usuario: arranca la app,
/// entra, explora, reserva y revisa.
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
