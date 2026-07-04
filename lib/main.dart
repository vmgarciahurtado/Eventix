import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/core/constants/fonts.dart';
import 'package:eventix/core/env/env.dart';
import 'package:eventix/core/l10n/app_localizations.dart';
import 'package:eventix/core/router/app_router.dart';
import 'package:eventix/core/theme/app_palette.dart';
import 'package:eventix/core/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // El `.env` no se versiona (se comparte por canal privado). Si falta o está
  // incompleto se muestra una pantalla de configuración en vez de crashear.
  try {
    await dotenv.load();
  } catch (_) {
    // Sin `.env`: Env devolverá valores vacíos y se mostrará _MissingEnvApp.
  }
  if (Env.supabaseUrl.isEmpty || Env.supabasePublishableKey.isEmpty) {
    runApp(const _MissingEnvApp());
    return;
  }
  await initializeDateFormatting('es');
  await Supabase.initialize(
    url: Env.supabaseUrl,
    publishableKey: Env.supabasePublishableKey,
  );
  runApp(const ProviderScope(child: MainApp()));
}

/// Pantalla mínima cuando faltan las variables de entorno: explica cómo
/// configurar el proyecto sin exponer ningún valor sensible.
class _MissingEnvApp extends StatelessWidget {
  const _MissingEnvApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: UiKitTheme.light(
        primary: AppPalette.primary,
        secondary: AppPalette.secondary,
        fontFamily: Fonts.poppins,
      ),
      home: const Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(UiSpacing.lg),
            child: Text(
              'Falta configurar el archivo .env.\n\n'
              'Copia .env.example como .env en la raíz del proyecto y usa '
              'los valores compartidos por canal privado. Luego vuelve a '
              'ejecutar la app.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeMode themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (BuildContext context) =>
          AppLocalizations.of(context).app_name,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('es'),
      theme: UiKitTheme.light(
        primary: AppPalette.primary,
        secondary: AppPalette.secondary,
        fontFamily: Fonts.poppins,
      ),
      darkTheme: UiKitTheme.dark(
        primary: AppPalette.primary,
        secondary: AppPalette.secondary,
        fontFamily: Fonts.poppins,
      ),
      themeMode: themeMode,
      routerConfig: appRouter,
    );
  }
}
