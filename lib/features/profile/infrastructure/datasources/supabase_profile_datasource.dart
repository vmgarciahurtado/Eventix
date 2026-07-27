import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/core/errors/supabase_guard.dart';
import 'package:eventix/features/profile/infrastructure/datasources/profile_datasource.dart';
import 'package:eventix/features/profile/infrastructure/models/remote_profile_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Implementación de [ProfileDatasource] sobre el cliente de Supabase.
///
/// Usa `auth.currentUser` para scopear la fila de `profiles`, pero no depende
/// de la feature auth: es el propio SDK quien conoce la sesión.
class SupabaseProfileDatasource implements ProfileDatasource {
  const SupabaseProfileDatasource(this._client);

  final SupabaseClient _client;

  @override
  Future<RemoteProfileModel?> fetchCurrentProfile() =>
      guardSupabaseCall(() async {
        final String? uid = _client.auth.currentUser?.id;
        if (uid == null) throw const UnauthorizedFailure();
        final Map<String, dynamic>? row = await _client
            .from('profiles')
            .select()
            .eq('id', uid)
            .maybeSingle();
        return row == null ? null : RemoteProfileModel.fromJson(row);
      });

  @override
  Future<void> completeOnboarding() => guardSupabaseCall(() async {
    final String? uid = _client.auth.currentUser?.id;
    if (uid == null) throw const UnauthorizedFailure();
    await _client
        .from('profiles')
        .update(<String, dynamic>{'onboarding_completed': true})
        .eq('id', uid);
  });
}
