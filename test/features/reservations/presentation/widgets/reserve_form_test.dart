import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/core/helpers/result.dart';
import 'package:eventix/features/events/di/events_di.dart';
import 'package:eventix/features/events/domain/usecases/get_event_availability.dart';
import 'package:eventix/features/reservations/di/reservations_di.dart';
import 'package:eventix/features/reservations/domain/entities/purchase_outcome.dart';
import 'package:eventix/features/reservations/domain/usecases/start_purchase.dart';
import 'package:eventix/features/reservations/presentation/widgets/quantity_stepper.dart';
import 'package:eventix/features/reservations/presentation/widgets/reserve_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/pump_app.dart';

class _MockStartPurchase extends Mock implements StartPurchase {}

class _MockGetEventAvailability extends Mock implements GetEventAvailability {}

void main() {
  late _MockStartPurchase startPurchase;
  late _MockGetEventAvailability getAvailability;

  setUpAll(initSpanishDates);

  setUp(() {
    startPurchase = _MockStartPurchase();
    getAvailability = _MockGetEventAvailability();
  });

  Future<void> pumpForm(
    WidgetTester tester, {
    double price = 80000,
    int available = 50,
  }) async {
    when(
      () => getAvailability.call(any()),
    ).thenAnswer((_) async => Success<int>(available));
    await pumpComponent(
      tester,
      ReserveForm(event: tEvent(price: price)),
      overrides: <Override>[
        startPurchaseProvider.overrideWithValue(startPurchase),
        getEventAvailabilityProvider.overrideWithValue(getAvailability),
      ],
    );
    await tester.pumpAndSettle();
  }

  void mockPurchaseOk() => when(
    () => startPurchase.call(
      eventId: any(named: 'eventId'),
      unitPrice: any(named: 'unitPrice'),
      quantity: any(named: 'quantity'),
      wantInvoice: any(named: 'wantInvoice'),
    ),
  ).thenAnswer(
    (_) async => Success<PurchaseOutcome>(
      PurchaseCompleted(reservation: tReservation()),
    ),
  );

  Finder plus() => find.widgetWithIcon(IconButton, Icons.add);

  testWidgets('arranca en un cupo y el total es el precio unitario', (
    WidgetTester tester,
  ) async {
    await pumpForm(tester);

    expect(find.text('1'), findsOneWidget);
    expect(find.text(r'$80.000'), findsNWidgets(2));
    expect(find.widgetWithText(UiButton, r'Pagar $80.000'), findsOneWidget);
  });

  testWidgets('subir la cantidad recalcula el total y el botón', (
    WidgetTester tester,
  ) async {
    await pumpForm(tester);

    await tester.tap(plus());
    await tester.pump();

    expect(find.text(r'$160.000'), findsOneWidget);
    expect(find.widgetWithText(UiButton, r'Pagar $160.000'), findsOneWidget);
  });

  testWidgets('un evento gratuito no ofrece factura ni habla de pagar', (
    WidgetTester tester,
  ) async {
    await pumpForm(tester, price: 0);

    expect(find.byType(UiCheckOption), findsNothing);
    expect(find.widgetWithText(UiButton, 'Reservar gratis'), findsOneWidget);
  });

  testWidgets('un evento pago ofrece la factura marcada', (
    WidgetTester tester,
  ) async {
    await pumpForm(tester);

    expect(find.byType(UiCheckOption), findsOneWidget);
    expect(
      tester.widget<UiCheckOption>(find.byType(UiCheckOption)).value,
      isTrue,
    );
  });

  testWidgets('la cantidad se acota a los cupos que quedan', (
    WidgetTester tester,
  ) async {
    await pumpForm(tester, available: 2);

    await tester.tap(plus());
    await tester.pump();
    expect(find.text('2'), findsOneWidget);

    expect(
      tester.widget<IconButton>(plus()).onPressed,
      isNull,
      reason: 'no debe poder pedir más cupos de los que hay',
    );
  });

  testWidgets('la cantidad nunca pasa del tope por compra del dominio', (
    WidgetTester tester,
  ) async {
    await pumpForm(tester, available: 1000);

    expect(
      tester.widget<QuantityStepper>(find.byType(QuantityStepper)).max,
      StartPurchase.maxPerPurchase,
    );
  });

  testWidgets('agotado deshabilita la compra', (WidgetTester tester) async {
    await pumpForm(tester, available: 0);

    final UiButton button = tester.widget<UiButton>(
      find.widgetWithText(UiButton, 'Agotado'),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('pedir la compra pide confirmación antes de cobrar', (
    WidgetTester tester,
  ) async {
    mockPurchaseOk();
    await pumpForm(tester);

    await tester.tap(find.widgetWithText(UiButton, r'Pagar $80.000'));
    await tester.pumpAndSettle();

    expect(find.text('Pagar con Stripe'), findsOneWidget);
    verifyNever(
      () => startPurchase.call(
        eventId: any(named: 'eventId'),
        unitPrice: any(named: 'unitPrice'),
        quantity: any(named: 'quantity'),
        wantInvoice: any(named: 'wantInvoice'),
      ),
    );
  });

  testWidgets('cancelar la confirmación no inicia ninguna compra', (
    WidgetTester tester,
  ) async {
    mockPurchaseOk();
    await pumpForm(tester);

    await tester.tap(find.widgetWithText(UiButton, r'Pagar $80.000'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    verifyNever(
      () => startPurchase.call(
        eventId: any(named: 'eventId'),
        unitPrice: any(named: 'unitPrice'),
        quantity: any(named: 'quantity'),
        wantInvoice: any(named: 'wantInvoice'),
      ),
    );
  });

  testWidgets('confirmar inicia la compra con lo que eligió el usuario', (
    WidgetTester tester,
  ) async {
    mockPurchaseOk();
    await pumpForm(tester);

    await tester.tap(plus());
    await tester.pump();
    await tester.tap(find.widgetWithText(UiButton, r'Pagar $160.000'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();

    verify(
      () => startPurchase.call(
        eventId: 'evt-1',
        unitPrice: 80000,
        quantity: 2,
        wantInvoice: true,
      ),
    ).called(1);
  });

  testWidgets('desmarcar la factura viaja en la compra', (
    WidgetTester tester,
  ) async {
    mockPurchaseOk();
    await pumpForm(tester);

    await tester.tapAt(
      tester.getTopLeft(find.byType(UiCheckOption)) + const Offset(12, 12),
    );
    await tester.pump();
    await tester.tap(find.widgetWithText(UiButton, r'Pagar $80.000'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();

    verify(
      () => startPurchase.call(
        eventId: 'evt-1',
        unitPrice: 80000,
        quantity: 1,
        wantInvoice: false,
      ),
    ).called(1);
  });

  testWidgets('un evento gratuito confirma sin mencionar el pago', (
    WidgetTester tester,
  ) async {
    mockPurchaseOk();
    await pumpForm(tester, price: 0);

    await tester.tap(find.widgetWithText(UiButton, 'Reservar gratis'));
    await tester.pumpAndSettle();

    expect(find.text('Pagar con Stripe'), findsNothing);
    expect(find.textContaining('gratuito'), findsOneWidget);
  });

  testWidgets('muestra la disponibilidad real del evento', (
    WidgetTester tester,
  ) async {
    await pumpForm(tester, available: 37);

    expect(find.text('37 de 300 cupos disponibles'), findsOneWidget);
  });
}
