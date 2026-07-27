import 'dart:async';

import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/core/extensions/snackbar_extension.dart';
import 'package:eventix/core/l10n/app_localizations.dart';
import 'package:eventix/core/widgets/async_error_view.dart';
import 'package:eventix/features/auth/domain/enums/otp_purpose.dart';
import 'package:eventix/features/auth/presentation/pages/verify_code_page.dart';
import 'package:eventix/features/auth/presentation/providers/register_provider.dart';
import 'package:eventix/features/auth/presentation/widgets/register_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RegisterPage extends ConsumerWidget {
  static const String routePath = '/register';

  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool loading = ref.watch(registerProvider).isLoading;

    ref.listen(registerProvider, (
      AsyncValue<String?>? previous,
      AsyncValue<String?> next,
    ) {
      switch (next) {
        case AsyncError<String?>(:final Object error):
          context.showSnack(failureMessage(error, l10n.error_unexpected));
        case AsyncData<String?>(value: final String email):
          context.showSnack(l10n.register_code_sent);
          unawaited(
            context.push(
              VerifyCodePage.routePath,
              extra: VerifyCodeArgs(email: email, purpose: OtpPurpose.signup),
            ),
          );
        default:
          break;
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(l10n.register_title)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(UiSpacing.large),
          child: RegisterForm(
            loading: loading,
            onSubmit: ref.read(registerProvider.notifier).register,
          ),
        ),
      ),
    );
  }
}
