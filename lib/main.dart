import 'package:eventix/core/env/env.dart';
import 'package:eventix/core/l10n/app_localizations.dart';
import 'package:eventix/core/router/app_router.dart';
import 'package:eventix/core/theme/app_theme.dart';
import 'package:eventix/core/widgets/missing_env_app.dart';
import 'package:eventix/features/app_config/di/app_config_di.dart';
import 'package:eventix/features/app_config/domain/entities/app_config.dart';
import 'package:eventix/features/app_config/presentation/providers/app_config_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load();
  } catch (_) {
    // Sin `.env`: se cae al chequeo de abajo y se muestra MissingEnvApp.
  }
  if (Env.supabaseUrl.isEmpty || Env.supabasePublishableKey.isEmpty) {
    runApp(const MissingEnvApp());
    return;
  }
  await initializeDateFormatting('es');
  await Supabase.initialize(
    url: Env.supabaseUrl,
    publishableKey: Env.supabasePublishableKey,
  );
  // Se resuelve antes de `runApp` para que la configuración sea síncrona en
  // toda la app: ninguna pantalla arranca con un estado de carga por esto.
  final AppConfig config = await loadStartupAppConfig();
  runApp(
    ProviderScope(
      overrides: <Override>[appConfigOverride(config)],
      child: const MainApp(),
    ),
  );
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppConfig config = ref.watch(appConfigProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (BuildContext context) =>
          AppLocalizations.of(context).app_name,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('es'),
      theme: AppTheme.from(config.brand),
      darkTheme: AppTheme.from(config.brand),
      themeMode: ThemeMode.dark,
      routerConfig: appRouter,
    );
  }
}
