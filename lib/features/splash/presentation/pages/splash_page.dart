import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/auth/domain/entities/app_user.dart';
import 'package:eventix/features/auth/presentation/pages/login_page.dart';
import 'package:eventix/features/auth/presentation/providers/auth_providers.dart';
import 'package:eventix/features/home/presentation/pages/home_page.dart';
import 'package:eventix/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashPage extends ConsumerStatefulWidget {
  static const String routePath = '/';

  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _decideNextRoute());
  }

  Future<void> _decideNextRoute() async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    final Session? session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      context.go(LoginPage.routePath);
      return;
    }

    final Result<AppUser?> profile = await ref
        .read(getCurrentProfileProvider)
        .call();
    if (!mounted) return;
    final bool onboardingDone = switch (profile) {
      Success<AppUser?>(data: final AppUser? data) =>
        data?.onboardingCompleted ?? true,
      FailureResult<AppUser?>() => true,
    };
    context.go(
      onboardingDone ? HomePage.routePath : OnboardingPage.routePath,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.confirmation_num_rounded,
              size: 72,
              color: context.colorScheme.primary,
            ),
            const SizedBox(height: UiSpacing.lg),
            const UiLoader(),
          ],
        ),
      ),
    );
  }
}
