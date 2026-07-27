import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/core/helpers/form_validators.dart';
import 'package:eventix/core/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

typedef LoginSubmit =
    void Function({required String email, required String password});

class LoginForm extends StatefulWidget {
  const LoginForm({
    required this.loading,
    required this.onSubmit,
    required this.onForgotPassword,
    super.key,
  });

  final bool loading;
  final LoginSubmit onSubmit;
  final VoidCallback onForgotPassword;

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSubmit(email: _email.text.trim(), password: _password.text);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          UiTextField(
            controller: _email,
            label: l10n.field_email_label,
            hint: l10n.field_email_hint,
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: FormValidators.email(
              emptyMsg: l10n.validator_email_empty,
              invalidMsg: l10n.validator_email_invalid,
            ),
          ),
          const SizedBox(height: UiSpacing.medium),
          UiTextField(
            controller: _password,
            label: l10n.field_password_label,
            prefixIcon: Icons.lock_outline,
            obscureText: true,
            textInputAction: TextInputAction.done,
            validator: FormValidators.password(
              emptyMsg: l10n.validator_password_empty,
              minMsg: l10n.validator_password_min,
            ),
          ),
          const SizedBox(height: UiSpacing.small),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: widget.loading ? null : widget.onForgotPassword,
              child: Text(l10n.login_forgot_password),
            ),
          ),
          const SizedBox(height: UiSpacing.medium),
          UiButton(
            label: l10n.login_submit,
            expanded: true,
            loading: widget.loading,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
