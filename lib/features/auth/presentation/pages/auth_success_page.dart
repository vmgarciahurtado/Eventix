import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Argumentos de [AuthSuccessPage], pasados vía `extra` de GoRouter.
class AuthSuccessArgs {
  const AuthSuccessArgs({
    required this.title,
    required this.buttonLabel,
    required this.targetRoute,
    this.message,
    this.signOutFirst = false,
  });

  final String title;
  final String buttonLabel;
  final String targetRoute;
  final String? message;

  /// Si es `true`, cierra la sesión antes de navegar (ej. tras cambiar la
  /// contraseña en el flujo de recuperación).
  final bool signOutFirst;
}

class AuthSuccessPage extends ConsumerWidget {
  static const String routePath = '/success';

  const AuthSuccessPage({required this.args, super.key});

  final AuthSuccessArgs args;

  Future<void> _onAction(BuildContext context, WidgetRef ref) async {
    if (args.signOutFirst) {
      await ref.read(signOutProvider).call();
    }
    if (!context.mounted) return;
    context.go(args.targetRoute);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: UiSuccessView(
          title: args.title,
          message: args.message,
          actionLabel: args.buttonLabel,
          onAction: () => _onAction(context, ref),
        ),
      ),
    );
  }
}
