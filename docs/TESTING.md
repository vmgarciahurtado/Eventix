# Pruebas

| | Archivos | Pruebas | Cobertura |
|---|---|---|---|
| App (`test/`) | 80 | 491 | **99.4 %** |
| Paquete `app_ui_kit` | 22 | 148 | **100 %** |
| Integración (`integration_test/`) | 7 + orquestador | 8 | contra Supabase real |

## Requisitos

- Flutter 3.44.2 y `.env` en la raíz.
- `lcov` para la cobertura: `brew install lcov` (macOS) o `apt install lcov`.
- Para integración: un dispositivo o simulador arrancado (`flutter devices`) y
  una cuenta de prueba ya verificada.

## Unitarias y de widget

```bash
flutter test
```

## Cobertura

```bash
./test/scripts/coverage.sh
```

```bash
./test/scripts/coverage.sh --html
```

Falla si baja del 80 %. `lib/core/l10n/` queda fuera del reporte por ser código
generado.

## Integración

```bash
flutter test integration_test/main_test.dart --dart-define=EVENTIX_TEST_EMAIL=tu@correo.com --dart-define=EVENTIX_TEST_PASSWORD=tu-clave
```

Sin las credenciales, las pruebas que necesitan sesión se marcan omitidas con el
motivo en la salida. No hay ningún dispositivo fijado en el código; si hay
varios conectados se elige con `-d <id>`.

## Paquete de diseño

```bash
cd ../app_ui_kit && flutter test
```

```bash
cd ../app_ui_kit && ./test/scripts/coverage.sh
```

## Estructura

`test/` refleja `lib/` archivo por archivo. Lo compartido está en
`test/helpers/`:

| Archivo | Para qué |
|---|---|
| `pump_app.dart` | `pumpPage`, `pumpComponent` y `pumpRoutes` con el tema y el locale reales |
| `fixtures.dart` | Datos de prueba |
| `test_container.dart` | `ProviderContainer` sin reintentos y `keepAlive()` |
| `fake_supabase.dart` | `SupabaseClient` real sobre un transporte falso |
| `fake_webview.dart` | `WebViewPlatform` de prueba para el checkout |

Integración: un archivo por tramo del flujo (`splash/`, `login/`, `onboarding/`,
`events/`, `event_detail/`, `reserve/`, `my_reservations/`) y `main_test.dart`
como único punto de entrada.

## Fuera de alcance

El pago real: la prueba de integración llega al diálogo de confirmación y
cancela, para no disparar un cobro en Stripe en cada corrida. Ese tramo se
muestra en el video de la entrega.

## Hallazgos

- `formatPrice` imprimía `80.000 $`. Corregido en `money_format.dart`.
- Riverpod 3 reintenta los `Failure` y la pantalla se queda en `AsyncLoading`
  unos 38 s antes de mostrar el error. Fijado en
  `test/core/providers/provider_retry_test.dart`, **sin corregir**: se apaga con
  `retry: (int retryCount, Object error) => null` en el `ProviderScope` de
  `main.dart` y es una decisión de producto.
