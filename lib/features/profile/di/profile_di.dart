import 'package:eventix/core/services/supabase/supabase_provider.dart';
import 'package:eventix/features/profile/domain/repositories/profile_repository.dart';
import 'package:eventix/features/profile/infrastructure/datasources/profile_datasource.dart';
import 'package:eventix/features/profile/infrastructure/datasources/supabase_profile_datasource.dart';
import 'package:eventix/features/profile/infrastructure/repositories/profile_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Composition root de la feature profile: expone SOLO interfaces.
final Provider<ProfileDatasource> profileDatasourceProvider =
    Provider<ProfileDatasource>(
      (Ref ref) => SupabaseProfileDatasource(ref.watch(supabaseClientProvider)),
    );

final Provider<ProfileRepository> profileRepositoryProvider =
    Provider<ProfileRepository>(
      (Ref ref) => ProfileRepositoryImpl(ref.watch(profileDatasourceProvider)),
    );
