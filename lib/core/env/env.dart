import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Acceso centralizado a las variables de entorno (cargadas desde `.env`
/// con `flutter_dotenv`). Reemplaza el enfoque con `envied` del base.
abstract final class Env {
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';

  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
}
