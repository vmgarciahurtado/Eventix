import 'dart:async';

import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/core/extensions/snackbar_extension.dart';
import 'package:eventix/core/helpers/form_validators.dart';
import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/auth/domain/entities/otp_purpose.dart';
import 'package:eventix/features/auth/presentation/pages/verify_code_page.dart';
import 'package:eventix/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ResetPasswordRequestPage extends ConsumerStatefulWidget {
  static const String routePath = '/reset-password';

  const ResetPasswordRequestPage({super.key});

  @override
  ConsumerState<ResetPasswordRequestPage> createState() =>
      _ResetPasswordRequestPageState();
}

class _ResetPasswordRequestPageState
    extends ConsumerState<ResetPasswordRequestPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final String email = _email.text.trim();
    final Result<void> result = await ref
        .read(sendPasswordResetProvider)
        .call(email: email);
    if (!mounted) return;
    setState(() => _loading = false);

    switch (result) {
      case Success<void>():
        context.showSnack('Te enviamos un código para restablecer');
        unawaited(
          context.push(
            VerifyCodePage.routePath,
            extra: VerifyCodeArgs(email: email, purpose: OtpPurpose.recovery),
          ),
        );
      case FailureResult<void>(failure: final Failure failure):
        context.showSnack(failure.userMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar contraseña')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(UiSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'Ingresa tu correo y te enviaremos un código para crear una '
                  'nueva contraseña.',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: UiSpacing.lg),
                UiTextField(
                  controller: _email,
                  label: 'Correo',
                  hint: 'tu@correo.com',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  validator: FormValidators.email,
                ),
                const SizedBox(height: UiSpacing.xl),
                UiButton(
                  label: 'Enviar código',
                  expanded: true,
                  loading: _loading,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
