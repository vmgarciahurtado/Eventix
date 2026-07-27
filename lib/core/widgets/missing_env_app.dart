import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/core/constants/fonts.dart';
import 'package:eventix/core/l10n/app_localizations.dart';
import 'package:eventix/core/theme/app_palette.dart';
import 'package:flutter/material.dart';

class MissingEnvApp extends StatelessWidget {
  const MissingEnvApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: UiKitTheme.light(
        primary: AppPalette.primary,
        secondary: AppPalette.secondary,
        fontFamily: Fonts.poppins,
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('es'),
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(UiSpacing.large),
            child: Builder(
              builder: (BuildContext context) => Text(
                AppLocalizations.of(context).missing_env_message,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
