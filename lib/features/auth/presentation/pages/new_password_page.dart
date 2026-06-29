import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/core/extensions/snackbar_extension.dart';
import 'package:eventix/core/helpers/form_validators.dart';
import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/auth/presentation/pages/auth_success_page.dart';
import 'package:eventix/features/auth/presentation/pages/login_page.dart';
import 'package:eventix/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class NewPasswordPage extends ConsumerStatefulWidget {
  static const String routePath = '/new-password';

  const NewPasswordPage({super.key});

  @override
  ConsumerState<NewPasswordPage> createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends ConsumerState<NewPasswordPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirm = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final Result<void> result = await ref
        .read(updatePasswordProvider)
        .call(newPassword: _password.text);
    if (!mounted) return;
    setState(() => _loading = false);

    switch (result) {
      case Success<void>():
        context.go(
          AuthSuccessPage.routePath,
          extra: const AuthSuccessArgs(
            title: '¡Contraseña actualizada!',
            message: 'Inicia sesión con tu nueva contraseña.',
            buttonLabel: 'Ir a iniciar sesión',
            targetRoute: LoginPage.routePath,
            signOutFirst: true,
          ),
        );
      case FailureResult<void>(failure: final Failure failure):
        context.showSnack(failure.userMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva contraseña')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(UiSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                UiTextField(
                  controller: _password,
                  label: 'Nueva contraseña',
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
                const SizedBox(height: UiSpacing.xl),
                UiButton(
                  label: 'Guardar contraseña',
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
