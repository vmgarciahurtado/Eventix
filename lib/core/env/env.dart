import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Acceso centralizado a las variables de entorno (cargadas desde `.env`
/// con `flutter_dotenv`). Reemplaza el enfoque con `envied` del base.
abstract final class Env {
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';

  /// Key pública del cliente. Acepta la nueva `sb_publishable_...`
  /// (`SUPABASE_PUBLISHABLE_KEY`) o, por compatibilidad, la anon legacy
  /// (`SUPABASE_ANON_KEY`).
  static String get supabasePublishableKey {
    return dotenv.env['SUPABASE_PUBLISHABLE_KEY'] ??
        dotenv.env['SUPABASE_ANON_KEY'] ??
        '';
  }
}
