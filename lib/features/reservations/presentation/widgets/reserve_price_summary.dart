import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/core/helpers/money_format.dart';
import 'package:eventix/core/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class ReservePriceSummary extends StatelessWidget {
  const ReservePriceSummary({
    required this.unitPrice,
    required this.total,
    super.key,
  });

  final double unitPrice;
  final double total;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Column(
      children: <Widget>[
        _PriceRow(
          label: l10n.reserve_unit_price,
          value: formatPrice(unitPrice, freeLabel: l10n.common_free),
        ),
        const SizedBox(height: UiSpacing.small),
        _PriceRow(
          label: l10n.reserve_total,
          value: formatPrice(total, freeLabel: l10n.common_free),
          emphasized: true,
        ),
      ],
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final TextStyle? labelStyle = emphasized
        ? context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
        : context.textTheme.bodyLarge;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(label, style: labelStyle),
        Text(
          value,
          style: emphasized
              ? labelStyle?.copyWith(color: context.colorScheme.primary)
              : labelStyle,
        ),
      ],
    );
  }
}
