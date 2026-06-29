import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Cliente único de Supabase, inyectado en los datasources.
///
/// `Supabase.initialize(...)` corre en `main()` antes de `runApp`, así que
/// `Supabase.instance.client` ya está listo al leer este provider.
final Provider<SupabaseClient> supabaseClientProvider =
    Provider<SupabaseClient>((Ref ref) => Supabase.instance.client);
