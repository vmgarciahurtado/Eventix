# Eventix

App Flutter de eventos: descubre y filtra fiestas, ve el detalle, reserva cupos
y paga con Stripe (o reserva gratis), y consulta "mis reservas". Backend en
**Supabase** (Postgres + Auth + Edge Functions) y design system propio en un
paquete aparte.

## Demo

[![Ver el recorrido de Eventix en Loom](https://cdn.loom.com/sessions/thumbnails/81bf4e023a97429c8a3a984037ba9d01-4a69d26109ea1417.gif)](https://www.loom.com/share/81bf4e023a97429c8a3a984037ba9d01)

### ▶︎ [Onboarding y reservas en Eventix con Stripe](https://www.loom.com/share/81bf4e023a97429c8a3a984037ba9d01) · 3:36

El recorrido completo de punta a punta, en orden:

| Momento | Qué se ve |
|---|---|
| **Registro y OTP** | alta de cuenta y verificación del código que llega por correo |
| **Onboarding** | preferencias iniciales |
| **Catálogo** | eventos con filtros por categoría y por ciudad (incluido el estado vacío cuando la ciudad no tiene fiestas) |
| **Detalle y reserva** | 4 cupos sobre un evento de $85.000 |
| **Pago** | Checkout de Stripe en WebView, confirmación server-side y la reserva reflejada en "mis reservas" |

---

## Stack

| Área | Elección |
|---|---|
| Estado / DI | **Riverpod 3** (`flutter_riverpod ^3.3.1`) **sin** anotaciones ni codegen |
| Navegación | **GoRouter** `^17.3.0`, rutas declaradas por feature |
| Backend | **Supabase** (`supabase_flutter ^2.8.0`): Postgres + Auth + Edge Functions |
| Pagos | **Stripe Checkout** vía Edge Functions (Deno) — sin secretos en el cliente |
| Design system | **`app_ui_kit`** ([repo aparte](https://github.com/vmgarciahurtado/app_ui_kit)) |
| Env vars | `flutter_dotenv` (`.env`, no versionado) |
| Localización | `flutter_localizations` + ARB (`gen-l10n`) |
| WebView | `webview_flutter` (hospeda el Checkout de Stripe) |
| Animación | `lottie` (a través del kit) |
| Tests | `flutter_test` + `mocktail` (sin codegen) |

> No hay archivos `*.g.dart`: nada de `build_runner`, `retrofit`, `envied` ni
> `riverpod_generator`. La DI es explícita por `ref.watch`.

---

## Requisitos previos

- **Flutter** con Dart SDK `^3.12.0`.
- Una cuenta/proyecto de **Supabase**.
- (Solo para probar pagos) una cuenta de **Stripe** en modo test.

---

## Puesta en marcha

### 1. Clonar los dos repos, uno al lado del otro

El design system se consume por **path**, así que Eventix no compila solo:

```bash
git clone https://github.com/vmgarciahurtado/app_ui_kit.git
git clone https://github.com/vmgarciahurtado/Eventix.git eventix
cd eventix && flutter pub get
```

```
<carpeta-padre>/
├── app_ui_kit/     ← el design system
└── eventix/        ← esta app
```

```yaml
# pubspec.yaml
app_ui_kit:
  path: ../app_ui_kit
```

Se eligió `path` porque el kit y la app evolucionaron a la vez. Para fijar una
versión y no depender de la carpeta hermana, basta cambiarlo por la dependencia
git apuntando a un tag:

```yaml
app_ui_kit:
  git:
    url: https://github.com/vmgarciahurtado/app_ui_kit.git
    ref: <tag-o-commit>
```

### 2. Variables de entorno (`.env`)

El `.env` **no se versiona** (contiene la config del proyecto Supabase y se
comparte por canal privado):

```bash
cp .env.example .env
```

```dotenv
SUPABASE_URL=https://<tu-proyecto>.supabase.co
SUPABASE_PUBLISHABLE_KEY=sb_publishable_...   # o la anon legacy (eyJ...)
```

Si falta o está incompleto, la app **no crashea**: muestra una pantalla
explicando qué falta (ver `main.dart`).

### 3. Base de datos y Edge Functions

**Esquema.** Aplica las migraciones **en orden**:

| Migración | Qué hace |
|---|---|
| `0001_profiles.sql` | `profiles` + RLS + trigger `handle_new_user` |
| `0002_events.sql` | `categories`, `cities`, `events` + RLS + seed inicial |
| `0003_reservations.sql` | `reservations`, `tickets` + RLS + triggers de cupos/tickets |
| `0004_..._security_definer.sql` | corrige RLS de los triggers (`SECURITY DEFINER`) |
| `0005_reservations_payment_core.sql` | núcleo transaccional: lock de cupos, gate de pago, expiración de pendings, vista `event_availability` |
| `0006_party_catalog_reset.sql` | **destructiva**: borra reservas, tickets y el catálogo previo, y siembra 5 categorías de fiesta + 8 eventos |
| `0007_event_image_url.sql` | `events.image_url` reemplaza a `image_key`: la imagen del evento pasa a ser un dato del backend |

> `supabase/setup_all.sql` es el combinado de `0001`→`0005` únicamente. Si lo
> usas, aplica `0006` y `0007` aparte.

Verifica: `select count(*) from events;` → **8**.

**Edge Functions** (carpeta `supabase/functions/`, requieren Stripe):

```bash
supabase functions deploy stripe-create-checkout
supabase functions deploy stripe-verify-checkout
supabase functions deploy stripe-return
supabase secrets set STRIPE_SECRET_KEY=sk_test_...
```

`supabase/config.toml` fija el `verify_jwt` de cada función: activo en las dos
primeras y **desactivado** en `stripe-return`, porque el navegador aterriza ahí
sin sesión al volver del Checkout.

### 4. Plantillas de email (OTP)

Dashboard → **Auth → Email Templates**: *Confirm signup* y *Reset Password*
deben incluir `{{ .Token }}`.

> El largo del código lo manda **Auth → Email OTP Length** y la app lo replica
> en `VerifyCodeForm.otpLength` (hoy **8**). Si cambias uno, cambia el otro: si
> no, el campo queda con más o menos casillas que el código del correo.

### 5. Ejecutar

```bash
flutter run
```

---

## Arquitectura

**Clean Architecture por feature**, con las dependencias apuntando hacia
adentro:

```
domain  ←  infrastructure  ←  presentation
```

```
lib/features/<feature>/
├── di/                 providers de Riverpod (composition root de la feature)
├── domain/
│   ├── entities/       clases Dart puras
│   ├── enums/          tipos del dominio
│   ├── repositories/   interfaces (abstract interface class)
│   └── usecases/       un archivo por caso de uso
├── infrastructure/
│   ├── datasources/    interface + impl Supabase
│   ├── models/         Remote*Model con fromJson
│   ├── mappers/        Remote*Model → entidad
│   └── repositories/   impl que devuelve Result<T>
├── presentation/
│   ├── pages/          ConsumerWidget: estado remoto y navegación
│   ├── providers/      un provider por archivo
│   └── widgets/        formularios y piezas con estado local
└── routes/             GoRoute(s) de la feature
```

Features: `auth`, `onboarding`, `events`, `reservations`, `payments`,
`profile`, `splash`.

- **DI**: cada feature expone sus dependencias en `di/<feat>_di.dart`, siempre
  contra **interfaces** (DIP), así que todo es override-able en tests.
- **Providers de acción**: el patrón es uniforme — guarda de doble toque,
  `AsyncLoading`, `await`, chequeo de `ref.mounted` y `switch` sobre el
  `Result` sellado. Sin `AsyncValue.guard` lanzando excepciones a propósito.
- **Páginas sin estado de formulario**: la página es `ConsumerWidget` y solo
  observa estado remoto y navega; el estado del formulario vive en un
  `StatefulWidget` de `presentation/widgets/`.
- **`core/`**: errores (`Failure`/`Result`), helpers (formatos, validators),
  widgets compartidos (`AsyncView`, `AsyncErrorView`, marca), extensiones de
  contexto, tema, router y l10n.

---

## Flujo de reserva y pago

El núcleo de la prueba. Diseño **reservar-primero → pagar → confirmar
server-side**, con el precio y la confirmación siempre autoritativos en el
servidor:

1. **Reserva pendiente**: se crea la reserva `pending` (descuenta cupo) antes
   del checkout. Los eventos **gratuitos** nacen `confirmed` directo.
2. **Checkout**: la Edge Function `stripe-create-checkout` calcula el precio
   **desde la BD** (nunca del cliente) y crea la sesión de Stripe; se paga en
   un WebView.
3. **Confirmación server-side**: al volver, `stripe-verify-checkout` verifica
   el pago contra Stripe y **confirma la reserva** (lo que dispara la
   generación de tickets). El cliente solo interpreta el resultado.
4. **Sin sobreventa**: el trigger de cupos bloquea la fila del evento
   (`FOR UPDATE`) para serializar reservas concurrentes.
5. **Sin cupo retenido**: los `pending` de más de 15 min dejan de contar; si el
   usuario cancela el pago, su reserva pendiente se borra y libera el cupo.
6. **Disponibilidad real**: la vista `event_availability` expone los cupos
   disponibles agregados, sin filtrar datos de otros usuarios.

La orquestación vive en el usecase `PurchaseTickets` (domain) y el
`PurchaseNotifier` (presentation), con estados explícitos (`PurchaseWorking`,
`PurchaseAwaitingPayment`, `PurchaseSuccess`, `PurchaseUnconfirmed`…); la
página solo reacciona a esos estados. Al confirmar se navega con `go` a una
pantalla de confirmación que **bloquea el retroceso** (`PopScope`): después de
pagar no debe existir forma de volver al formulario de reserva.

---

## Manejo de errores

Flujo tipado, sin `Either` ni paquetes externos:

```
Datasource (guardSupabaseCall → mapSupabaseError)  →  lanza Failure
Repository (executeRepositoryCall)                 →  Result<T> (Success | FailureResult)
UseCase                                            →  Result<T> sin modificar
Notifier (switch sobre el Result)                  →  AsyncData | AsyncError
UI (.when(error:) / showFailure)                   →  failure.userMessage
```

- `mapSupabaseError` traduce `AuthException`, `PostgrestException` (incl.
  `P0001` de los triggers → `ValidationFailure`), `FunctionException` y errores
  de red (`AuthRetryableFetchException` → `ConnectionFailure`).
- `UnexpectedFailure` **nunca** filtra el detalle técnico a la UI (queda para
  logs); el detalle del backend solo se anexa en `kDebugMode`.

---

## Diseño

El tema es `UiKitTheme.dark` del kit tal cual, sin configuración: colores,
superficies y tipografía vienen del sistema de diseño. La app es **solo
oscura**.

- **Paleta**: vive en el sistema de diseño (`UiPalette.dark` de `app_ui_kit`),
  tomada del icono: amarillo neón `#F2F04B` + magenta `#E64BC8` sobre negro
  `#0B0709`. Las superficies son explícitas en el kit porque Material 3 deriva
  superficies verdosas de un amarillo tan saturado.
- **Marca**: solo dos imágenes, siempre detrás de un widget de `core/widgets/`
  para que ninguna página escriba una ruta de asset. `AppLogo` usa el lockup
  (splash, registro) y `AppIconBadge` el icono (esquina del login).
- **Mascota** (`AppCharacter`): protagonista del login y presente en los
  estados vacíos. Deliberadamente **no** aparece en los estados de error: un
  personaje simpático choca con "algo falló".
- **Imágenes de evento**: vienen de `events.image_url`. Mientras cargan se deja
  un fondo liso y si fallan —o si la fila no trae URL— aparece el marcador de
  "sin imagen". Son estados distintos a propósito: el marcador afirma que no
  hay foto, y mostrarlo mientras descarga diría algo falso.

---

## Tests

```bash
flutter test
```

**90 tests** en 21 archivos, con `mocktail` y sin codegen. La cobertura apunta
a la lógica que puede romperse de verdad: mapeo de errores de Supabase,
`getOrThrow`, parsing de `fromJson` (incluidos payloads malformados), los paths
de error de los repositorios, `EventFilter`/`ReservationStatus`, las guardas de
doble toque de los notifiers, y el usecase transaccional `PurchaseTickets`
(gratis vs pago, cancelación del pending, verificación del pago).

---

## Decisiones de diseño

- **Riverpod sin anotaciones**: DI explícita y legible, sin paso de codegen.
- **Sin secretos en el cliente**: la `publishable key` de Supabase es pública
  por diseño; el `STRIPE_SECRET_KEY` vive solo en las Edge Functions.
- **RLS own-rows**: cada usuario solo ve/crea sus propias reservas y tickets;
  la validación de cupos y la confirmación de pago corren con `SECURITY
  DEFINER`.
- **La imagen es un dato, no un asset**: `events.image_url` en vez de un
  archivo por evento. Antes había un degradado por categoría como respaldo,
  pero los assets nunca existieron y ese "respaldo" era el diseño real del
  catálogo; con la URL en la BD el respaldo volvió a ser lo que debía.
- **Usecases passthrough**: se conservan por convención de la arquitectura del
  equipo; la lógica de negocio real (compra, cupos, post-login) vive en domain.
- **`app_ui_kit` como repo aparte**: el design system es reutilizable entre
  apps, así que no se copia dentro de Eventix.