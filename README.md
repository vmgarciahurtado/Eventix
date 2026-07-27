# Eventix

App Flutter de eventos: descubre y filtra eventos, ve el detalle, reserva
cupos y paga con Stripe (o reserva gratis), y consulta "mis reservas".
Backend en **Supabase** (Postgres + Auth + Edge Functions).

---

## Tabla de contenido
- [Stack](#stack)
- [Requisitos previos](#requisitos-previos)
- [Puesta en marcha](#puesta-en-marcha)
  - [1. Clonar el proyecto](#1-clonar-el-proyecto)
  - [2. Variables de entorno (`.env`)](#2-variables-de-entorno-env)
  - [3. Base de datos y Edge Functions](#3-base-de-datos-y-edge-functions)
  - [4. Plantillas de email (OTP)](#4-plantillas-de-email-otp)
  - [5. Ejecutar](#5-ejecutar)
- [Arquitectura](#arquitectura)
- [Flujo de reserva y pago](#flujo-de-reserva-y-pago)
- [Manejo de errores](#manejo-de-errores)
- [Tests](#tests)
- [Decisiones de diseño](#decisiones-de-diseño)

---

## Stack

| Área | Elección |
|---|---|
| Estado / DI | **Riverpod 3** (`flutter_riverpod ^3.3.1`) **sin** anotaciones ni codegen |
| Navegación | **GoRouter** `^17.3.0` con guard de sesión reactivo |
| Backend | **Supabase** (`supabase_flutter ^2.8.0`): Postgres + Auth + Edge Functions |
| Pagos | **Stripe Checkout** vía Edge Functions (Deno) — sin secretos en el cliente |
| Design system | **`app_ui_kit`** (dependencia git desde GitHub) |
| Env vars | `flutter_dotenv` (`.env`, no versionado) |
| Localización | `flutter_localizations` + ARB (`gen-l10n`) |
| WebView | `webview_flutter` (hospeda el Checkout de Stripe) |
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

### 1. Clonar el proyecto

```bash
git clone https://github.com/vmgarciahurtado/Eventix.git eventix
cd eventix
flutter pub get
```

El design system `app_ui_kit` se consume como **dependencia git desde GitHub**
(https://github.com/vmgarciahurtado/app_ui_kit), declarada en `pubspec.yaml`:

```yaml
app_ui_kit:
  git:
    url: https://github.com/vmgarciahurtado/app_ui_kit.git
    ref: <tag-o-commit>
```

### 2. Variables de entorno (`.env`)

El `.env` **no se versiona** (contiene la config del proyecto Supabase y se
comparte por canal privado). Copia la plantilla y complétala con los valores
que se te entregaron:

```bash
cp .env.example .env
```

```dotenv
# .env
SUPABASE_URL=https://<tu-proyecto>.supabase.co
SUPABASE_PUBLISHABLE_KEY=sb_publishable_...   # o la anon legacy (eyJ...)
```

Si el `.env` falta o está incompleto, la app **no crashea**: muestra una
pantalla de configuración explicando qué falta (ver `main.dart`).

### 3. Base de datos y Edge Functions

**Esquema.** Aplica las migraciones en orden. La forma más rápida es pegar
`supabase/setup_all.sql` completo en el **SQL editor** de Supabase (es la
concatenación fiel de `supabase/migrations/0001…0005`, idempotente). O una a
una:

| Migración | Qué hace |
|---|---|
| `0001_profiles.sql` | `profiles` + RLS + trigger `handle_new_user` |
| `0002_events.sql` | `categories`, `cities`, `events` + RLS + seed (8 eventos) |
| `0003_reservations.sql` | `reservations`, `tickets` + RLS + triggers de cupos/tickets |
| `0004_..._security_definer.sql` | corrige RLS de los triggers (SECURITY DEFINER) |
| `0005_reservations_payment_core.sql` | núcleo transaccional: lock de cupos, gate de pago, expiración de pendings, vista `event_availability`, seed idempotente |

Verifica: `select count(*) from events;` → debe dar **8**.

**Edge Functions** (carpeta `supabase/functions/`, requieren Stripe):

```bash
supabase functions deploy stripe-create-checkout
supabase functions deploy stripe-verify-checkout
supabase functions deploy stripe-return
supabase secrets set STRIPE_SECRET_KEY=sk_test_...
```

### 4. Plantillas de email (OTP)

En el dashboard → **Auth → Email Templates**, las plantillas *Confirm signup*
y *Reset Password* deben incluir `{{ .Token }}` (OTP de **6 dígitos**; la
longitud es configurable en Auth → Email OTP Length y debe coincidir con la
constante del cliente).

### 5. Ejecutar

```bash
flutter run
```

Flujo esperable: registro → OTP → onboarding → eventos → filtros → detalle →
reservar → (pago Stripe o reserva gratis) → mis reservas.

---

## Arquitectura

**Clean Architecture por feature**, con dependencias apuntando hacia adentro:

```
domain  ←  infrastructure  ←  presentation
```

```
lib/features/<feature>/
├── di/                 providers de Riverpod (composition root de la feature)
├── domain/
│   ├── entities/       clases Dart puras
│   ├── repositories/   interfaces (abstract interface class)
│   └── usecases/       un archivo por caso de uso
├── infrastructure/
│   ├── datasources/    interface + impl Supabase
│   ├── models/         Remote*Model con fromJson
│   ├── mappers/        Remote*Model → entidad
│   └── repositories/   impl que devuelve Result<T>
├── presentation/
│   ├── pages/
│   ├── providers/      estado de UI / notifiers de acción
│   └── widgets/
└── routes/             GoRoute(s) de la feature
```

- **DI**: cada feature expone sus dependencias en `di/<feat>_di.dart`, siempre
  contra **interfaces** (DIP), por lo que todo es override-able en tests.
- **Router**: `appRouterProvider` (en `core/router/`) con `redirect` de sesión
  que consulta el `AuthRepository` (no `Supabase.instance`) y se refresca con
  `authStateChanges()`. El guard es testeable con overrides.
- **`core/`**: errores (`Failure`/`Result`), helpers (formatos, validators),
  widgets compartidos (`AsyncView`, `AsyncErrorView`), extensiones de contexto,
  router y l10n.

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
   el pago en Stripe y **confirma la reserva** (que dispara la generación de
   tickets). El cliente solo interpreta el resultado.
4. **Sin sobreventa**: el trigger de cupos bloquea la fila del evento
   (`FOR UPDATE`) para serializar reservas concurrentes.
5. **Sin cupo retenido**: los `pending` de más de 15 min dejan de contar; si el
   usuario cancela el pago, su reserva pendiente se borra y libera el cupo.
6. **Disponibilidad real**: la vista `event_availability` expone los cupos
   disponibles (agregados) sin filtrar datos de otros usuarios.

La orquestación vive en el usecase `PurchaseTickets` (domain) y el
`PurchaseNotifier` (presentation) con estados explícitos; la página solo
reacciona a esos estados.

---

## Manejo de errores

Flujo tipado, sin `Either` ni paquetes externos:

```
Datasource (guardSupabaseCall → mapSupabaseError)  →  lanza Failure
Repository (executeRepositoryCall)                 →  Result<T> (Success | FailureResult)
UseCase                                            →  Result<T> sin modificar
Notifier / Provider (getOrThrow)                   →  AsyncError
UI (.when(error:) / showFailure)                   →  failure.userMessage
```

- `mapSupabaseError` traduce `AuthException`, `PostgrestException` (incl.
  `P0001` de los triggers → `ValidationFailure`), `FunctionException` y errores
  de red (`AuthRetryableFetchException` → `ConnectionFailure`).
- `UnexpectedFailure` **nunca** filtra el detalle técnico a la UI (queda para
  logs); la UI ve un mensaje genérico.

---

## Tests

```bash
flutter test
```

`mocktail` sin codegen. Cobertura enfocada en la lógica real: mapeo de errores
de Supabase, `getOrThrow`, parsing de `fromJson` (incl. payloads malformados),
paths de error de los repositorios, `EventFilter`/`ReservationStatus`, y el
usecase transaccional `PurchaseTickets` (gratis vs pago, cancelación del
pending, verificación de pago).

---

## Decisiones de diseño

- **Riverpod sin anotaciones**: DI explícita y legible, sin paso de codegen.
- **Sin secretos en el cliente**: la `publishable key` de Supabase es pública
  por diseño; el `STRIPE_SECRET_KEY` vive solo en las Edge Functions.
- **RLS own-rows**: cada usuario solo ve/crea sus propias reservas y tickets;
  la validación de cupos y la confirmación de pago corren con `SECURITY
  DEFINER`.
- **Usecases passthrough**: se conservan por convención de la arquitectura del
  equipo; la lógica de negocio real (compra, cupos, post-login) vive en domain.
- **`app_ui_kit` como repo aparte**: el design system es reutilizable entre
  apps; por eso se consume por `path` y no se copia dentro de Eventix.
