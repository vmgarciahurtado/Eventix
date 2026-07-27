import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/core/helpers/form_validators.dart';
import 'package:eventix/core/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class ResetPasswordForm extends StatefulWidget {
  const ResetPasswordForm({
    required this.loading,
    required this.onSubmit,
    super.key,
  });

  final bool loading;
  final void Function({required String email}) onSubmit;

  @override
  State<ResetPasswordForm> createState() => _ResetPasswordFormState();
}

class _ResetPasswordFormState extends State<ResetPasswordForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSubmit(email: _email.text.trim());
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
            textInputAction: TextInputAction.done,
            validator: FormValidators.email(
              emptyMsg: l10n.validator_email_empty,
              invalidMsg: l10n.validator_email_invalid,
            ),
          ),
          const SizedBox(height: UiSpacing.extraLarge),
          UiButton(
            label: l10n.reset_password_submit,
            expanded: true,
            loading: widget.loading,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
