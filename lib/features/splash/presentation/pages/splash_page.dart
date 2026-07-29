import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/core/l10n/app_localizations.dart';
import 'package:eventix/core/widgets/app_logo.dart';
import 'package:eventix/features/auth/di/auth_di.dart';
import 'package:eventix/features/auth/domain/enums/post_auth_destination.dart';
import 'package:eventix/features/auth/routes/post_auth_destination_routing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SplashPage extends ConsumerStatefulWidget {
  static const String routePath = '/';

  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  static const double _logoWidth = 220;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _decideNextRoute());
  }

  Future<void> _decideNextRoute() async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    try {
      final PostAuthDestination destination = await ref
          .read(resolvePostAuthDestinationProvider)
          .call()
          .timeout(const Duration(seconds: 5));
      if (!mounted) return;
      context.go(destination.routePath);
    } catch (_) {
      if (!mounted) return;
      context.go(PostAuthDestination.home.routePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const AppLogo(width: _logoWidth),
              const SizedBox(height: UiSpacing.large),
              Text(
                AppLocalizations.of(context).app_tagline.toUpperCase(),
                textAlign: TextAlign.center,
                style: context.textTheme.labelSmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: UiSpacing.extraLarge),
              UiLoader(color: context.colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}
