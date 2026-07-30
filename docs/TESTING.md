# Estrategia de pruebas

Qué se probó, por qué eso y no otra cosa, y qué queda deliberadamente fuera.

| | Archivos | Pruebas | Cobertura |
|---|---|---|---|
| **App** (`test/`) | 59 | 328 | **85.4 %** |
| **Paquete `app_ui_kit`** (`test/`) | 3 | 46 | **96.2 %** |
| **Integración** (`integration_test/`) | 7 + orquestador | 8 | contra Supabase real |

## Cómo correr

```bash
flutter test                    # unitarias + widget
./tool/coverage.sh              # cobertura, falla si baja de 80 %
./tool/coverage.sh --html       # además abre el reporte navegable
```

Integración, sobre un dispositivo o simulador ya arrancado:

```bash
flutter test integration_test/main_test.dart --dart-define=EVENTIX_TEST_EMAIL=tu@correo.com --dart-define=EVENTIX_TEST_PASSWORD=tu-clave
```

Las credenciales entran por `--dart-define` y **nunca** viven en el repositorio.
Sin ellas, las pruebas que necesitan sesión se marcan omitidas con el motivo
visible en la salida, en vez de fallar con un error que no explica nada. La
cuenta tiene que estar ya verificada: el registro pide un código por correo que
no se puede automatizar.

El paquete de diseño se prueba en su propio repositorio:

```bash
cd ../app_ui_kit && flutter test
```

## Qué se decidió probar

El criterio no fue "cubrir líneas" sino **qué duele si se rompe**. En orden:

**1. El dinero.** `StartPurchase` y `PurchaseNotifier` son los únicos puntos
donde la app puede cobrar. `purchase_provider_test.dart` fija las reglas que no
pueden fallar nunca: un doble toque no cobra dos veces; cancelar libera el cupo
retenido sin gastar una verificación; un pago cobrado cuya reserva no se pudo
confirmar **no** borra la reserva, porque ese registro es el rastro que soporte
necesita; y un fallo al liberar el cupo no tapa el resultado del pago.

**2. Los flujos completos, como flujos.** Login, catálogo y reserva se prueban
de pantalla en pantalla con el router real y rutas de marca en los destinos
(`password_recovery_flow_test.dart` monta las cuatro pantallas del flujo
juntas). Probar cada pantalla por separado diría que todas funcionan y nada
sobre si encajan.

**3. Transformación de datos.** Todo `fromJson` se prueba con la fila completa,
con la fila incompleta que realmente manda PostgREST (joins vacíos, números como
`double`) y con el payload roto que debe lanzar. Un `status` desconocido cae en
`pending` en vez de romper la pantalla; un `paid` que no sea `true` literal
nunca cuenta como cobro.

**4. Estados de error y de vacío.** Es lo que el usuario ve cuando algo sale
mal, y lo que nadie prueba a mano. Se verifica también que **ningún detalle
técnico se filtre a la pantalla**: un `UnexpectedFailure` muestra "Algo salió
mal", no el código de Postgres.

**5. Componentes del sistema de diseño.** En el paquete, con foco en los tres
más nuevos, que no tenían ninguna prueba: `UiOtpField` (largo configurable,
avance de foco, `onCompleted` una sola vez, solo dígitos, retroceso),
`UiCheckOption` (la fila completa alterna, pero el enlace dispara su propio
callback sin aceptar) y `UiSuccessView`.

**6. El cableado.** `wiring_test.dart` construye el grafo de dependencias real
con el cliente de Supabase sustituido. Un provider mal cableado no es un error
de compilación: explota al abrir la pantalla.

## Dos defectos que encontraron estas pruebas

**`formatPrice` imprimía `80.000 $`.** El patrón del locale `es_CO` de `intl`
pone el símbolo detrás, que no es como se escriben los pesos acá. Corregido en
`money_format.dart` fijando el orden con `customPattern` y dejando que el locale
siga decidiendo el separador de miles.

**Riverpod 3 reintenta y tapa la pantalla de error.** Riverpod 3 reintenta por
defecto cualquier throwable que no sea un `Error`, y todo `Failure` de la app es
un `Exception`. Mientras reintenta —10 intentos con backoff de 200 ms a 6,4 s,
unos 38 s en total— el estado se queda en `AsyncLoading`: **nunca** pasa por
`AsyncError`, así que `AsyncErrorView` y su botón "Reintentar" no aparecen hasta
que se agotan los intentos. Sin red, el usuario ve el loader medio minuto.

Está fijado en `test/core/providers/provider_retry_test.dart` y **no** corregido:
apagarlo cambia el comportamiento de todas las pantallas y esa es una decisión de
producto, no de la fase de pruebas. Se apaga en una línea, en el `ProviderScope`
de `main.dart`:

```dart
ProviderScope(
  retry: (int retryCount, Object error) => null,
  child: const MainApp(),
);
```

## Qué queda fuera, a propósito

**Los cinco datasources de Supabase** (126 líneas, el 45 % de lo que falta).
Son adaptadores sobre el *query builder* de PostgREST: simularlo exige encadenar
mocks de `SupabaseQueryBuilder` → `PostgrestFilterBuilder` → `PostgrestTransformBuilder`,
y el resultado prueba la maqueta, no el código. Se cubren donde sí dicen algo:
en las pruebas de integración, contra el Supabase real. Lo que sí tiene prueba
unitaria es su lógica propia, ya extraída: el mapeo de errores
(`map_supabase_error_test.dart`) y el parseo de filas.

**`CheckoutWebViewPage`** (29 líneas). Es un `WebView` sobre una web de
terceros; en pruebas no hay plataforma que lo renderice.

**El pago real.** La prueba de integración llega al diálogo de confirmación y
cancela. Automatizarlo dispararía un cobro en Stripe en cada corrida. Ese tramo
se demuestra en el video de la entrega.

**`lib/core/l10n/`** sale del reporte: es salida de `flutter gen-l10n`, y
contarla mide al generador.

## Cómo está organizado

`test/` refleja `lib/` archivo por archivo. Lo compartido vive en
`test/helpers/`:

- **`pump_app.dart`** — `pumpPage` (páginas, que traen su `Scaffold`),
  `pumpComponent` (componentes sueltos) y `pumpRoutes` (lo que navega, con un
  `GoRouter` real). Los tres montan el tema propio y el locale `es` reales: si el
  entorno del test no fuera el de la app, una prueba en verde no diría nada.
- **`fixtures.dart`** — datos con la forma que de verdad llega del backend.
- **`test_container.dart`** — `testContainer()` apaga los reintentos de Riverpod
  y `keepAlive()` sostiene el provider, que en Riverpod 3 es `autoDispose` por
  defecto y se recicla antes de que la prueba lea el resultado.

Las de integración siguen la misma idea: un archivo por tramo del flujo y
`main_test.dart` como único punto de entrada, que inicializa Supabase una vez y
llama a los demás en el orden del usuario.

Dos reglas que no son obvias y que ya costaron una corrección:

- **Cada prueba monta la app.** `testWidgets` destruye el árbol de widgets al
  terminar, así que no se hereda la pantalla de la prueba anterior. Por eso
  `launchAt(tester, ruta)` hace `pumpWidget` y después navega. El `appRouter` es
  global y sí conserva su ubicación; el árbol no.
- **Cada prueba se para sola.** `ensureSignedIn()` abre sesión por API si no hay
  una. El login por pantalla se prueba en `login/`; los demás tramos no deberían
  caerse porque ese falló ni depender de haber corrido después de él.

Y un antipatrón que hay que evitar acá: omitir la prueba cuando un `find` no
encuentra algo. Un `markTestSkipped` mal puesto convierte un fallo real en una
omisión en verde. Los guards de "no hay eventos" van **después** de afirmar que
la pantalla está montada.
