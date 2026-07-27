import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/core/extensions/snackbar_extension.dart';
import 'package:eventix/core/l10n/app_localizations.dart';
import 'package:eventix/core/widgets/async_error_view.dart';
import 'package:eventix/features/auth/presentation/pages/login_page.dart';
import 'package:eventix/features/auth/presentation/providers/logout_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// El reset deja una sesión temporal abierta: hay que cerrarla antes de
/// volver al login.
class NewPasswordSuccessPage extends ConsumerWidget {
  static const String routePath = '/new-password/success';

  const NewPasswordSuccessPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    ref.listen(logoutProvider, (
      AsyncValue<void>? previous,
      AsyncValue<void> next,
    ) {
      switch (next) {
        case AsyncError<void>(:final Object error):
          context.showSnack(failureMessage(error, l10n.error_unexpected));
        case AsyncData<void>():
          context.go(LoginPage.routePath);
        default:
          break;
      }
    });

    return Scaffold(
      body: SafeArea(
        child: UiSuccessView(
          title: l10n.new_password_success_title,
          message: l10n.new_password_success_message,
          actionLabel: l10n.new_password_success_button,
          onAction: ref.read(logoutProvider.notifier).logout,
        ),
      ),
    );
  }
}
