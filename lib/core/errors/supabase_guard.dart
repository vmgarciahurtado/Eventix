import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/core/errors/map_supabase_error.dart';

/// Ejecuta una llamada al cliente de Supabase traduciendo cualquier error a
/// la jerarquía sellada [Failure] (vía [mapSupabaseError]).
///
/// Es el guard común de todos los datasources remotos: los repositorios
/// capturan el [Failure] resultante con `executeRepositoryCall`.
Future<T> guardSupabaseCall<T>(Future<T> Function() fn) async {
  try {
    return await fn();
  } catch (e) {
    throw mapSupabaseError(e);
  }
}
