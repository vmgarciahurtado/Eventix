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

class RegisterPage extends ConsumerStatefulWidget {
  static const String routePath = '/register';

  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _lastName = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirm = TextEditingController();
  bool _acceptedTerms = false;
  bool _loading = false;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptedTerms) {
      context.showSnack('Debes aceptar los términos y condiciones');
      return;
    }
    setState(() => _loading = true);

    final String email = _email.text.trim();
    final Result<void> result = await ref.read(registerUserProvider).call(
      email: email,
      password: _password.text,
      firstName: _firstName.text.trim(),
      lastName: _lastName.text.trim(),
    );
    if (!mounted) return;
    setState(() => _loading = false);

    switch (result) {
      case Success<void>():
        context.showSnack('Te enviamos un código a tu correo');
        unawaited(
          context.push(
            VerifyCodePage.routePath,
            extra: VerifyCodeArgs(email: email, purpose: OtpPurpose.signup),
          ),
        );
      case FailureResult<void>(failure: final Failure failure):
        context.showSnack(failure.userMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(UiSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                UiTextField(
                  controller: _firstName,
                  label: 'Nombre',
                  prefixIcon: Icons.person_outline,
                  textInputAction: TextInputAction.next,
                  validator: (String? v) =>
                      FormValidators.required(v, 'Ingresa tu nombre'),
                ),
                const SizedBox(height: UiSpacing.md),
                UiTextField(
                  controller: _lastName,
                  label: 'Apellido',
                  prefixIcon: Icons.person_outline,
                  textInputAction: TextInputAction.next,
                  validator: (String? v) =>
                      FormValidators.required(v, 'Ingresa tu apellido'),
                ),
                const SizedBox(height: UiSpacing.md),
                UiTextField(
                  controller: _email,
                  label: 'Correo',
                  hint: 'tu@correo.com',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: FormValidators.email,
                ),
                const SizedBox(height: UiSpacing.md),
                UiTextField(
                  controller: _password,
                  label: 'Contraseña',
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  textInputAction: TextInputAction.next,
                  validator: FormValidators.password,
                ),
                const SizedBox(height: UiSpacing.md),
                UiTextField(
                  controller: _confirm,
                  label: 'Confirmar contraseña',
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  validator: (String? v) =>
                      FormValidators.confirmPassword(v, _password.text),
                ),
                const SizedBox(height: UiSpacing.lg),
                UiCheckOption(
                  value: _acceptedTerms,
                  onChanged: (bool v) => setState(() => _acceptedTerms = v),
                  label: 'Acepto los',
                  linkText: 'términos y condiciones',
                ),
                const SizedBox(height: UiSpacing.xl),
                UiButton(
                  label: 'Registrarme',
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
