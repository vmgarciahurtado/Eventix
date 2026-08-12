import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/core/extensions/snackbar_extension.dart';
import 'package:eventix/core/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class VerifyCodeForm extends StatefulWidget {
  const VerifyCodeForm({
    required this.loading,
    required this.onSubmit,
    required this.onResend,
    super.key,
  });

  /// Único lugar donde se define el largo del código: debe coincidir con
  /// Auth → Email OTP Length en Supabase, que hoy está en 8.
  static const int otpLength = 8;

  final bool loading;
  final void Function(String code) onSubmit;
  final VoidCallback onResend;

  @override
  State<VerifyCodeForm> createState() => _VerifyCodeFormState();
}

class _VerifyCodeFormState extends State<VerifyCodeForm> {
  String _code = '';

  void _submit() {
    if (_code.length < VerifyCodeForm.otpLength) {
      context.showSnack(AppLocalizations.of(context).verify_incomplete_code);
      return;
    }
    widget.onSubmit(_code);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        UiOtpField(
          length: VerifyCodeForm.otpLength,
          onChanged: (String code) => _code = code,
          onCompleted: (String code) {
            _code = code;
            _submit();
          },
        ),
        const SizedBox(height: UiSpacing.extraLarge),
        UiButton(
          label: l10n.verify_submit,
          expanded: true,
          loading: widget.loading,
          onPressed: _submit,
        ),
        const SizedBox(height: UiSpacing.small),
        Center(
          child: UiButton(
            label: l10n.verify_resend,
            variant: UiButtonVariant.ghost,
            onPressed: widget.loading ? null : widget.onResend,
          ),
        ),
      ],
    );
  }
}
