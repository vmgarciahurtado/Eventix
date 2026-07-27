import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/core/extensions/snackbar_extension.dart';
import 'package:eventix/core/l10n/app_localizations.dart';
import 'package:eventix/core/widgets/async_error_view.dart';
import 'package:eventix/features/auth/presentation/pages/new_password_success_page.dart';
import 'package:eventix/features/auth/presentation/providers/new_password_provider.dart';
import 'package:eventix/features/auth/presentation/widgets/new_password_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class NewPasswordPage extends ConsumerWidget {
  static const String routePath = '/new-password';

  const NewPasswordPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool loading = ref.watch(newPasswordProvider).isLoading;

    ref.listen(newPasswordProvider, (
      AsyncValue<void>? previous,
      AsyncValue<void> next,
    ) {
      switch (next) {
        case AsyncError<void>(:final Object error):
          context.showSnack(failureMessage(error, l10n.error_unexpected));
        case AsyncData<void>():
          context.go(NewPasswordSuccessPage.routePath);
        default:
          break;
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(l10n.new_password_title)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(UiSpacing.large),
          child: NewPasswordForm(
            loading: loading,
            onSubmit: ref.read(newPasswordProvider.notifier).updatePassword,
          ),
        ),
      ),
    );
  }
}
