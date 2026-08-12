import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Acceso centralizado a las variables de entorno (cargadas desde `.env`
/// con `flutter_dotenv`). Reemplaza el enfoque con `envied` del base.
abstract final class Env {
  static String get supabaseUrl => _read('SUPABASE_URL');

  /// Key pública del cliente. Acepta la nueva `sb_publishable_...`
  /// (`SUPABASE_PUBLISHABLE_KEY`) o, por compatibilidad, la anon legacy
  /// (`SUPABASE_ANON_KEY`).
  static String get supabasePublishableKey {
    final String publishable = _read('SUPABASE_PUBLISHABLE_KEY');
    return publishable.isNotEmpty ? publishable : _read('SUPABASE_ANON_KEY');
  }

  /// Lee una variable sin lanzar si `dotenv.load()` falló (por ejemplo, cuando
  /// no existe `.env`): en ese caso devuelve vacío y la app muestra
  /// `MissingEnvApp` en vez de reventar en `main`.
  static String _read(String key) {
    if (!dotenv.isInitialized) return '';
    return dotenv.env[key] ?? '';
  }
}
