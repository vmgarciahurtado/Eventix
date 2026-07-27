import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/core/helpers/form_validators.dart';
import 'package:eventix/core/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class NewPasswordForm extends StatefulWidget {
  const NewPasswordForm({
    required this.loading,
    required this.onSubmit,
    super.key,
  });

  final bool loading;
  final void Function({required String newPassword}) onSubmit;

  @override
  State<NewPasswordForm> createState() => _NewPasswordFormState();
}

class _NewPasswordFormState extends State<NewPasswordForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirm = TextEditingController();

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSubmit(newPassword: _password.text);
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
            controller: _password,
            label: l10n.field_new_password_label,
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
          const SizedBox(height: UiSpacing.extraLarge),
          UiButton(
            label: l10n.new_password_submit,
            expanded: true,
            loading: widget.loading,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
