import 'dart:async';

import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/core/extensions/snackbar_extension.dart';
import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/auth/domain/entities/otp_purpose.dart';
import 'package:eventix/features/auth/presentation/pages/new_password_page.dart';
import 'package:eventix/features/auth/presentation/providers/auth_providers.dart';
import 'package:eventix/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Argumentos de [VerifyCodePage], pasados vía `extra` de GoRouter.
class VerifyCodeArgs {
  const VerifyCodeArgs({required this.email, required this.purpose});

  final String email;
  final OtpPurpose purpose;
}

class VerifyCodePage extends ConsumerStatefulWidget {
  static const String routePath = '/verify';

  const VerifyCodePage({required this.args, super.key});

  final VerifyCodeArgs args;

  @override
  ConsumerState<VerifyCodePage> createState() => _VerifyCodePageState();
}

class _VerifyCodePageState extends ConsumerState<VerifyCodePage> {
  bool _loading = false;
  String _code = '';

  Future<void> _verify() async {
    if (_code.length < 6) {
      context.showSnack('Ingresa el código completo');
      return;
    }
    setState(() => _loading = true);

    final Result<void> result = await ref.read(verifyOtpProvider).call(
      email: widget.args.email,
      token: _code,
      purpose: widget.args.purpose,
    );
    if (!mounted) return;

    switch (result) {
      case Success<void>():
        _onVerified();
      case FailureResult<void>(failure: final Failure failure):
        setState(() => _loading = false);
        context.showSnack(failure.userMessage);
    }
  }

  void _onVerified() {
    switch (widget.args.purpose) {
      case OtpPurpose.signup:
        context.go(OnboardingPage.routePath);
      case OtpPurpose.recovery:
        unawaited(context.push(NewPasswordPage.routePath));
    }
  }

  Future<void> _resend() async {
    final Result<void> result = await ref.read(resendOtpProvider).call(
      email: widget.args.email,
      purpose: widget.args.purpose,
    );
    if (!mounted) return;
    final String message = switch (result) {
      Success<void>() => 'Código reenviado',
      FailureResult<void>(failure: final Failure failure) =>
        failure.userMessage,
    };
    context.showSnack(message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(UiSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Verifica tu correo',
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: UiSpacing.xs),
              Text(
                'Escribe el código que enviamos a ${widget.args.email}',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: UiSpacing.xl),
              UiOtpField(
                onChanged: (String code) => _code = code,
                onCompleted: (String code) {
                  _code = code;
                  unawaited(_verify());
                },
              ),
              const SizedBox(height: UiSpacing.xl),
              UiButton(
                label: 'Verificar',
                expanded: true,
                loading: _loading,
                onPressed: _verify,
              ),
              const SizedBox(height: UiSpacing.sm),
              Center(
                child: TextButton(
                  onPressed: _loading ? null : _resend,
                  child: const Text('Reenviar código'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
