import 'dart:async';

import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/core/extensions/snackbar_extension.dart';
import 'package:eventix/core/l10n/app_localizations.dart';
import 'package:eventix/core/widgets/app_character.dart';
import 'package:eventix/core/widgets/app_icon_badge.dart';
import 'package:eventix/core/widgets/async_error_view.dart';
import 'package:eventix/features/auth/domain/enums/post_auth_destination.dart';
import 'package:eventix/features/auth/presentation/pages/register_page.dart';
import 'package:eventix/features/auth/presentation/pages/reset_password_request_page.dart';
import 'package:eventix/features/auth/presentation/providers/login_provider.dart';
import 'package:eventix/features/auth/presentation/widgets/login_form.dart';
import 'package:eventix/features/auth/routes/post_auth_destination_routing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends ConsumerWidget {
  static const String routePath = '/login';

  static const double _characterHeight = 200;
  static const double _badgeSize = 44;

  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool loading = ref.watch(loginProvider).isLoading;

    ref.listen(loginProvider, (
      AsyncValue<PostAuthDestination?>? previous,
      AsyncValue<PostAuthDestination?> next,
    ) {
      switch (next) {
        case AsyncError<PostAuthDestination?>(:final Object error):
          context.showSnack(failureMessage(error, l10n.error_unexpected));
        case AsyncData<PostAuthDestination?>(
          value: final PostAuthDestination destination,
        ):
          context.go(destination.routePath);
        default:
          break;
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(UiSpacing.large),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const Center(child: AppCharacter(height: _characterHeight)),
                    const SizedBox(height: UiSpacing.medium),
                    Text(
                      l10n.login_welcome,
                      textAlign: TextAlign.center,
                      style: context.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: UiSpacing.extraSmall),
                    Text(
                      l10n.login_subtitle,
                      textAlign: TextAlign.center,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: UiSpacing.extraLarge),
                    LoginForm(
                      loading: loading,
                      onSubmit: ref.read(loginProvider.notifier).signIn,
                      onForgotPassword: () => unawaited(
                        context.push(ResetPasswordRequestPage.routePath),
                      ),
                    ),
                    const SizedBox(height: UiSpacing.medium),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          l10n.login_no_account,
                          style: context.textTheme.bodyMedium,
                        ),
                        TextButton(
                          onPressed: loading
                              ? null
                              : () => unawaited(
                                  context.push(RegisterPage.routePath),
                                ),
                          child: Text(l10n.login_register_cta),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Positioned(
              top: UiSpacing.small,
              right: UiSpacing.large,
              child: AppIconBadge(size: _badgeSize),
            ),
          ],
        ),
      ),
    );
  }
}
