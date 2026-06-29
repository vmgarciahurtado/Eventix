import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/core/errors/failure.dart';
import 'package:eventix/core/extensions/snackbar_extension.dart';
import 'package:eventix/core/helpers/form_validators.dart';
import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/core/widgets/app_logo.dart';
import 'package:eventix/features/auth/domain/entities/app_user.dart';
import 'package:eventix/features/auth/presentation/pages/register_page.dart';
import 'package:eventix/features/auth/presentation/pages/reset_password_request_page.dart';
import 'package:eventix/features/auth/presentation/providers/auth_providers.dart';
import 'package:eventix/features/home/presentation/pages/home_page.dart';
import 'package:eventix/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends ConsumerStatefulWidget {
  static const String routePath = '/login';

  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final Result<void> result = await ref
        .read(signInProvider)
        .call(email: _email.text.trim(), password: _password.text);
    if (!mounted) return;

    switch (result) {
      case Success<void>():
        await _routeAfterLogin();
      case FailureResult<void>(failure: final Failure failure):
        setState(() => _loading = false);
        context.showSnack(failure.userMessage);
    }
  }

  Future<void> _routeAfterLogin() async {
    final Result<AppUser?> profile = await ref
        .read(getCurrentProfileProvider)
        .call();
    if (!mounted) return;
    final bool onboardingDone = switch (profile) {
      Success<AppUser?>(data: final AppUser? data) =>
        data?.onboardingCompleted ?? true,
      FailureResult<AppUser?>() => true,
    };
    context.go(
      onboardingDone ? HomePage.routePath : OnboardingPage.routePath,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(UiSpacing.lg),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const AppLogo(size: 72),
                  const SizedBox(height: UiSpacing.md),
                  Text(
                    'Bienvenido a Eventix',
                    textAlign: TextAlign.center,
                    style: context.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: UiSpacing.xs),
                  Text(
                    'Inicia sesión para descubrir eventos',
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: UiSpacing.xl),
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
                    textInputAction: TextInputAction.done,
                    validator: FormValidators.password,
                  ),
                  const SizedBox(height: UiSpacing.sm),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _loading
                          ? null
                          : () => context.push(
                              ResetPasswordRequestPage.routePath,
                            ),
                      child: const Text('¿Olvidaste tu contraseña?'),
                    ),
                  ),
                  const SizedBox(height: UiSpacing.md),
                  UiButton(
                    label: 'Iniciar sesión',
                    expanded: true,
                    loading: _loading,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: UiSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        '¿No tienes cuenta?',
                        style: context.textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: _loading
                            ? null
                            : () => context.push(RegisterPage.routePath),
                        child: const Text('Regístrate'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
