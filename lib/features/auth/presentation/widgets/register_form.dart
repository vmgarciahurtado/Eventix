import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/core/extensions/snackbar_extension.dart';
import 'package:eventix/core/helpers/form_validators.dart';
import 'package:eventix/core/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

typedef RegisterSubmit =
    void Function({
      required String email,
      required String password,
      required String firstName,
      required String lastName,
    });

class RegisterForm extends StatefulWidget {
  const RegisterForm({
    required this.loading,
    required this.onSubmit,
    super.key,
  });

  final bool loading;
  final RegisterSubmit onSubmit;

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _lastName = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirm = TextEditingController();
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptedTerms) {
      context.showSnack(AppLocalizations.of(context).register_terms_required);
      return;
    }
    widget.onSubmit(
      email: _email.text.trim(),
      password: _password.text,
      firstName: _firstName.text.trim(),
      lastName: _lastName.text.trim(),
    );
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
            controller: _firstName,
            label: l10n.field_first_name_label,
            prefixIcon: Icons.person_outline,
            textInputAction: TextInputAction.next,
            validator: FormValidators.required(
              message: l10n.validator_first_name_required,
            ),
          ),
          const SizedBox(height: UiSpacing.medium),
          UiTextField(
            controller: _lastName,
            label: l10n.field_last_name_label,
            prefixIcon: Icons.person_outline,
            textInputAction: TextInputAction.next,
            validator: FormValidators.required(
              message: l10n.validator_last_name_required,
            ),
          ),
          const SizedBox(height: UiSpacing.medium),
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
            textInputAction: TextInputAction.next,
            validator: FormValidators.password(
              emptyMsg: l10n.validator_password_empty,
              minMsg: l10n.validator_password_min,
            ),
          ),
          const SizedBox(height: UiSpacing.medium),
          UiTextField(
            controller: _confirm,
            label: l10n.field_confirm_password_label,
            prefixIcon: Icons.lock_outline,
            obscureText: true,
            textInputAction: TextInputAction.done,
            validator: FormValidators.confirmPassword(
              () => _password.text,
              emptyMsg: l10n.validator_confirm_password_empty,
              mismatchMsg: l10n.validator_confirm_password_mismatch,
            ),
          ),
          const SizedBox(height: UiSpacing.large),
          UiCheckOption(
            value: _acceptedTerms,
            onChanged: (bool v) => setState(() => _acceptedTerms = v),
            label: l10n.register_accept_terms_label,
            linkText: l10n.register_terms_link,
          ),
          const SizedBox(height: UiSpacing.extraLarge),
          UiButton(
            label: l10n.register_submit,
            expanded: true,
            loading: widget.loading,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
