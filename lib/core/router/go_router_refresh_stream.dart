import 'dart:async';

import 'package:flutter/foundation.dart';

/// Adapta un [Stream] a [Listenable] para usarlo como `refreshListenable` de
/// GoRouter. Cada evento del stream (p. ej. cambios de sesión de Supabase)
/// vuelve a evaluar el `redirect` del router.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
