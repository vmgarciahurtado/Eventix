import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/core/helpers/money_format.dart';
import 'package:eventix/core/l10n/app_localizations.dart';
import 'package:eventix/features/events/domain/entities/event.dart';
import 'package:eventix/features/events/presentation/providers/event_availability_provider.dart';
import 'package:eventix/features/reservations/domain/usecases/start_purchase_use_case.dart';
import 'package:eventix/features/reservations/presentation/providers/purchase_provider.dart';
import 'package:eventix/features/reservations/presentation/providers/purchase_state.dart';
import 'package:eventix/features/reservations/presentation/widgets/quantity_stepper.dart';
import 'package:eventix/features/reservations/presentation/widgets/reserve_event_header.dart';
import 'package:eventix/features/reservations/presentation/widgets/reserve_price_summary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Cantidad, resumen de precio y confirmación de la compra. La página se
/// encarga de reaccionar al estado resultante.
class ReserveForm extends ConsumerStatefulWidget {
  const ReserveForm({required this.event, super.key});

  final Event event;

  @override
  ConsumerState<ReserveForm> createState() => _ReserveFormState();
}

class _ReserveFormState extends ConsumerState<ReserveForm> {
  int _quantity = 1;
  bool _wantInvoice = true;

  /// Tope por compra: el máximo lo fija el dominio y aquí se acota a los
  /// cupos que quedan.
  int _maxQuantity(int? available) {
    return (available ?? StartPurchaseUseCase.maxPerPurchase).clamp(
      1,
      StartPurchaseUseCase.maxPerPurchase,
    );
  }

  Future<void> _startPurchase(int quantity, double total) async {
    final Event event = widget.event;
    final bool isFree = total <= 0;
    final AppLocalizations l10n = AppLocalizations.of(context);

    final bool? confirmed = await UiConfirmDialog.show(
      context: context,
      title: isFree ? l10n.action_reserve : l10n.reserve_confirm_pay_title,
      message: isFree
          ? l10n.reserve_confirm_free_message(quantity, event.title)
          : l10n.reserve_confirm_pay_message(
              formatPrice(total, freeLabel: l10n.common_free),
              quantity,
              event.title,
            ),
    );
    if (confirmed != true || !mounted) return;

    await ref
        .read(purchaseProvider.notifier)
        .start(
          eventId: event.id,
          unitPrice: event.price,
          quantity: quantity,
          wantInvoice: _wantInvoice,
        );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Event event = widget.event;
    final PurchaseState purchase = ref.watch(purchaseProvider);
    final bool loading =
        purchase is PurchaseWorking || purchase is PurchaseAwaitingPayment;
    final AsyncValue<int> availableAsync = ref.watch(
      eventAvailabilityProvider(event.id),
    );
    final int? available = availableAsync.value;
    final int max = _maxQuantity(available);
    final int quantity = _quantity > max ? max : _quantity;
    final double total = event.price * quantity;
    final bool isFree = total <= 0;
    final bool soldOut = available != null && available <= 0;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(UiSpacing.large),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ReserveEventHeader(event: event, available: availableAsync),
            const SizedBox(height: UiSpacing.extraLarge),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                UiText(
                  l10n.reserve_quantity_label,
                  style: UiTextStyle.subtitle,
                ),
                QuantityStepper(
                  value: quantity,
                  max: max,
                  onChanged: loading
                      ? null
                      : (int v) => setState(() => _quantity = v),
                ),
              ],
            ),
            const Divider(height: UiSpacing.extraLarge),
            ReservePriceSummary(unitPrice: event.price, total: total),
            if (!isFree) ...<Widget>[
              const SizedBox(height: UiSpacing.large),
              UiCheckOption(
                value: _wantInvoice,
                onChanged: loading
                    ? (_) {}
                    : (bool v) => setState(() => _wantInvoice = v),
                label: l10n.reserve_invoice_option,
              ),
            ],
            const SizedBox(height: UiSpacing.extraLarge),
            UiButton(
              label: soldOut
                  ? l10n.common_sold_out
                  : isFree
                  ? l10n.reserve_free_button
                  : l10n.reserve_pay_button(
                      formatPrice(total, freeLabel: l10n.common_free),
                    ),
              expanded: true,
              loading: loading,
              onPressed: soldOut ? null : () => _startPurchase(quantity, total),
            ),
          ],
        ),
      ),
    );
  }
}
