import 'dart:async';

import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/core/extensions/snackbar_extension.dart';
import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/core/l10n/app_localizations.dart';
import 'package:eventix/core/widgets/async_error_view.dart';
import 'package:eventix/features/auth/domain/enums/otp_purpose.dart';
import 'package:eventix/features/auth/presentation/pages/new_password_page.dart';
import 'package:eventix/features/auth/presentation/providers/verify_code_provider.dart';
import 'package:eventix/features/auth/presentation/widgets/verify_code_form.dart';
import 'package:eventix/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Se pasan vía `extra` de GoRouter.
class VerifyCodeArgs {
  const VerifyCodeArgs({required this.email, required this.purpose});

  final String email;
  final OtpPurpose purpose;
}

class VerifyCodePage extends ConsumerWidget {
  static const String routePath = '/verify';

  const VerifyCodePage({required this.args, super.key});

  final VerifyCodeArgs args;

  void _onVerified(BuildContext context) {
    switch (args.purpose) {
      case OtpPurpose.signup:
        context.go(OnboardingPage.routePath);
      case OtpPurpose.recovery:
        unawaited(context.push(NewPasswordPage.routePath));
    }
  }

  Future<void> _resend(BuildContext context, WidgetRef ref) async {
    final Result<void> result = await ref
        .read(verifyCodeProvider.notifier)
        .resend(email: args.email, purpose: args.purpose);
    if (!context.mounted) return;

    context.showSnack(switch (result) {
      Success<void>() => AppLocalizations.of(context).verify_code_resent,
      FailureResult<void>(:final Failure failure) => failure.userMessage,
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool loading = ref.watch(verifyCodeProvider).isLoading;

    ref.listen(verifyCodeProvider, (
      AsyncValue<void>? previous,
      AsyncValue<void> next,
    ) {
      switch (next) {
        case AsyncError<void>(:final Object error):
          context.showSnack(failureMessage(error, l10n.error_unexpected));
        case AsyncData<void>():
          _onVerified(context);
        default:
          break;
      }
    });

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(UiSpacing.large),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                l10n.verify_title,
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: UiSpacing.extraSmall),
              Text(
                l10n.verify_sent_to(args.email),
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: UiSpacing.extraLarge),
              VerifyCodeForm(
                loading: loading,
                onSubmit: (String code) => unawaited(
                  ref
                      .read(verifyCodeProvider.notifier)
                      .verify(
                        email: args.email,
                        token: code,
                        purpose: args.purpose,
                      ),
                ),
                onResend: () => unawaited(_resend(context, ref)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
