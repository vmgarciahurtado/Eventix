-- setup_all.sql — GENERADO: concatenación de migrations/0001..0005 en orden.
-- Camino rápido de instalación: pegar completo en el SQL editor de Supabase.
-- Equivale a aplicar las migraciones una a una (idempotente: re-ejecutarlo
-- no duplica seed ni rompe objetos existentes).

-- ============================================================================
-- >>> migrations/0001_profiles.sql
-- ============================================================================
-- Fase A — Perfiles de usuario
-- Aplicar en el SQL editor de Supabase (o vía MCP una vez autenticado).

create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  email text,
  first_name text,
  last_name text,
  onboarding_completed boolean not null default false,
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

-- Cada usuario solo puede leer/actualizar su propio perfil.
drop policy if exists "profiles_select_own" on public.profiles;
create policy "profiles_select_own"
  on public.profiles for select
  using (auth.uid() = id);

drop policy if exists "profiles_update_own" on public.profiles;
create policy "profiles_update_own"
  on public.profiles for update
  using (auth.uid() = id)
  with check (auth.uid() = id);

-- Crea el perfil automáticamente al registrarse, copiando los metadatos
-- (first_name / last_name) enviados en el signUp.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, email, first_name, last_name)
  values (
    new.id,
    new.email,
    new.raw_user_meta_data ->> 'first_name',
    new.raw_user_meta_data ->> 'last_name'
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ============================================================================
-- >>> migrations/0002_events.sql
-- ============================================================================
-- Fase B — Catálogo de eventos
-- Aplicar en el SQL editor de Supabase (o vía MCP una vez autenticado).

create table if not exists public.categories (
  id bigint primary key,
  name text not null,
  slug text not null unique
);

create table if not exists public.cities (
  id bigint primary key,
  name text not null
);

create table if not exists public.events (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text not null default '',
  category_id bigint references public.categories (id),
  city_id bigint references public.cities (id),
  starts_at timestamptz not null,
  price numeric not null default 0,
  capacity integer not null default 0,
  image_key text,
  created_at timestamptz not null default now()
);

-- RLS: lectura para cualquier usuario autenticado.
alter table public.categories enable row level security;
alter table public.cities enable row level security;
alter table public.events enable row level security;

drop policy if exists "categories_read" on public.categories;
create policy "categories_read" on public.categories
  for select to authenticated using (true);

drop policy if exists "cities_read" on public.cities;
create policy "cities_read" on public.cities
  for select to authenticated using (true);

drop policy if exists "events_read" on public.events;
create policy "events_read" on public.events
  for select to authenticated using (true);

-- ---------------------------------------------------------------------------
-- Seed
-- ---------------------------------------------------------------------------
insert into public.categories (id, name, slug) values
  (1, 'Música', 'musica'),
  (2, 'Tecnología', 'tecnologia'),
  (3, 'Deportes', 'deportes'),
  (4, 'Arte', 'arte'),
  (5, 'Gastronomía', 'gastronomia')
on conflict (id) do nothing;

insert into public.cities (id, name) values
  (1, 'Bogotá'),
  (2, 'Medellín'),
  (3, 'Cali'),
  (4, 'Barranquilla')
on conflict (id) do nothing;

insert into public.events
  (title, description, category_id, city_id, starts_at, price, capacity, image_key)
values
  ('Festival Indie Bogotá',
   'Una noche con las mejores bandas independientes del país.',
   1, 1, now() + interval '7 days', 80000, 300, 'festival_indie'),
  ('Cumbre de IA y Flutter',
   'Charlas y talleres sobre inteligencia artificial y desarrollo móvil.',
   2, 1, now() + interval '14 days', 120000, 150, 'cumbre_ia'),
  ('Maratón de Medellín',
   'Recorre la ciudad de la eterna primavera en esta maratón anual.',
   3, 2, now() + interval '21 days', 50000, 1000, 'maraton_medellin'),
  ('Expo Arte Contemporáneo',
   'Exposición de artistas emergentes latinoamericanos.',
   4, 2, now() + interval '10 days', 30000, 200, 'expo_arte'),
  ('Festival Gastronómico Cali',
   'Sabores del Pacífico y cocina de autor en un solo lugar.',
   5, 3, now() + interval '5 days', 60000, 250, 'gastro_cali'),
  ('Concierto Sinfónico',
   'La orquesta filarmónica interpreta clásicos del cine.',
   1, 3, now() + interval '30 days', 95000, 400, 'sinfonico'),
  ('Hackathon Caribe',
   '48 horas creando soluciones tecnológicas frente al mar.',
   2, 4, now() + interval '18 days', 0, 120, 'hackathon_caribe'),
  ('Clásico de Fútbol',
   'El partido más esperado de la temporada.',
   3, 4, now() + interval '3 days', 70000, 5000, 'clasico_futbol')
on conflict do nothing;

-- ============================================================================
-- >>> migrations/0003_reservations.sql
-- ============================================================================
-- Fase C — Reservas y tickets
-- Aplicar en el SQL editor de Supabase (o vía MCP una vez autenticado).

create table if not exists public.reservations (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade
    default auth.uid(),
  event_id uuid not null references public.events (id) on delete cascade,
  quantity integer not null check (quantity > 0),
  status text not null default 'confirmed'
    check (status in ('pending', 'confirmed')),
  created_at timestamptz not null default now()
);

create table if not exists public.tickets (
  id uuid primary key default gen_random_uuid(),
  reservation_id uuid not null references public.reservations (id)
    on delete cascade,
  code text not null,
  created_at timestamptz not null default now()
);

alter table public.reservations enable row level security;
alter table public.tickets enable row level security;

-- Cada usuario solo ve/crea sus propias reservas.
drop policy if exists "reservations_select_own" on public.reservations;
create policy "reservations_select_own" on public.reservations
  for select to authenticated using (user_id = auth.uid());

drop policy if exists "reservations_insert_own" on public.reservations;
create policy "reservations_insert_own" on public.reservations
  for insert to authenticated with check (user_id = auth.uid());

drop policy if exists "tickets_select_own" on public.tickets;
create policy "tickets_select_own" on public.tickets
  for select to authenticated using (
    exists (
      select 1 from public.reservations r
      where r.id = reservation_id and r.user_id = auth.uid()
    )
  );

-- Valida cupos disponibles antes de insertar la reserva.
create or replace function public.check_event_capacity()
returns trigger
language plpgsql
as $$
declare
  reserved integer;
  cap integer;
begin
  select coalesce(sum(quantity), 0) into reserved
  from public.reservations where event_id = new.event_id;

  select capacity into cap from public.events where id = new.event_id;

  if reserved + new.quantity > cap then
    raise exception 'No hay cupos suficientes para este evento';
  end if;
  return new;
end;
$$;

drop trigger if exists before_reservation_capacity on public.reservations;
create trigger before_reservation_capacity
  before insert on public.reservations
  for each row execute function public.check_event_capacity();

-- Genera un ticket por cupo reservado.
create or replace function public.generate_tickets()
returns trigger
language plpgsql
as $$
begin
  insert into public.tickets (reservation_id, code)
  select
    new.id,
    upper(substr(replace(gen_random_uuid()::text, '-', ''), 1, 8))
  from generate_series(1, new.quantity);
  return new;
end;
$$;

drop trigger if exists after_reservation_tickets on public.reservations;
create trigger after_reservation_tickets
  after insert on public.reservations
  for each row execute function public.generate_tickets();

-- ============================================================================
-- >>> migrations/0004_trigger_functions_security_definer.sql
-- ============================================================================
-- Fase C (fix) — Los triggers de reservas deben correr con privilegios
-- elevados:
--   * generate_tickets() inserta en public.tickets (que solo tiene política
--     de SELECT). Sin SECURITY DEFINER, RLS bloquea el INSERT con
--     "new row violates row-level security policy for table tickets".
--   * check_event_capacity() debe contar TODAS las reservas del evento; bajo
--     la RLS del usuario solo veía las propias y validaba mal el cupo.

create or replace function public.check_event_capacity()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  reserved integer;
  cap integer;
begin
  select coalesce(sum(quantity), 0) into reserved
  from public.reservations where event_id = new.event_id;

  select capacity into cap from public.events where id = new.event_id;

  if reserved + new.quantity > cap then
    raise exception 'No hay cupos suficientes para este evento';
  end if;
  return new;
end;
$$;

create or replace function public.generate_tickets()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.tickets (reservation_id, code)
  select
    new.id,
    upper(substr(replace(gen_random_uuid()::text, '-', ''), 1, 8))
  from generate_series(1, new.quantity);
  return new;
end;
$$;

-- ============================================================================
-- >>> migrations/0005_reservations_payment_core.sql
-- ============================================================================
-- 0005 — Núcleo transaccional de reservas y pagos.
--
-- Problemas que corrige:
--   (a) Sobreventa: el chequeo de cupos hacía SUM sin lock; dos inserts
--       concurrentes pasaban ambos la validación. Ahora se bloquea la fila
--       del evento (FOR UPDATE) para serializar reservas del mismo evento.
--   (b) Pago desacoplado: nada exigía haber pagado. Ahora los eventos pagos
--       solo pueden insertarse con status 'pending'; la confirmación la hace
--       la Edge Function `stripe-verify-checkout` (service role) tras
--       verificar el pago en Stripe. Los eventos gratuitos sí pueden nacer
--       'confirmed'.
--   (c) Tickets prematuros: se generaban al insertar (incluso pending).
--       Ahora se generan al quedar 'confirmed'.
--   (d) Cupo retenido para siempre: los 'pending' con más de 15 minutos
--       dejan de contar para el cupo (expiración implícita).
--   (e) Cancelación: el usuario puede borrar sus propias reservas 'pending'
--       (p. ej. si cancela el pago), liberando el cupo.
--   (f) Disponibilidad real: vista `event_availability` con los cupos
--       disponibles por evento (la RLS de reservations solo deja ver las
--       propias; la vista agrega con privilegios del owner y solo expone
--       conteos, no datos de otros usuarios).
--   (g) Seed idempotente: unique en events.image_key para que el seed pueda
--       usar `on conflict (image_key) do nothing`.

-- Las reservas nacen pendientes salvo que se indique lo contrario.
alter table public.reservations alter column status set default 'pending';

-- (a) + (b): validación de cupos con lock y gate de pago.
create or replace function public.check_event_capacity()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  reserved integer;
  ev_capacity integer;
  ev_price numeric;
begin
  -- Serializa las reservas de un mismo evento: la transacción concurrente
  -- espera aquí hasta que esta confirme o aborte.
  select e.capacity, e.price into ev_capacity, ev_price
  from public.events e
  where e.id = new.event_id
  for update;

  if ev_capacity is null then
    raise exception 'El evento no existe';
  end if;

  -- Los eventos pagos solo pueden nacer 'pending'. La confirmación ocurre
  -- server-side (Edge Function con service role) tras verificar el pago.
  if new.status = 'confirmed' and ev_price > 0 then
    raise exception 'Los eventos pagos requieren confirmación de pago';
  end if;

  select coalesce(sum(quantity), 0) into reserved
  from public.reservations
  where event_id = new.event_id
    and (
      status = 'confirmed'
      or (status = 'pending'
          and created_at > now() - interval '15 minutes')
    );

  if reserved + new.quantity > ev_capacity then
    raise exception 'No hay cupos suficientes para este evento';
  end if;
  return new;
end;
$$;

-- (c): tickets solo cuando la reserva queda confirmada (insert directo de
-- eventos gratuitos, o update pending→confirmed al verificar el pago).
create or replace function public.generate_tickets()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.status <> 'confirmed' then
    return new;
  end if;
  if tg_op = 'UPDATE' and old.status = 'confirmed' then
    return new; -- ya estaba confirmada: no duplicar tickets
  end if;

  insert into public.tickets (reservation_id, code)
  select
    new.id,
    upper(substr(replace(gen_random_uuid()::text, '-', ''), 1, 8))
  from generate_series(1, new.quantity);
  return new;
end;
$$;

drop trigger if exists after_reservation_tickets on public.reservations;
create trigger after_reservation_tickets
  after insert or update of status on public.reservations
  for each row execute function public.generate_tickets();

-- (e): cancelar (borrar) reservas propias que sigan pendientes.
drop policy if exists "reservations_delete_own_pending" on public.reservations;
create policy "reservations_delete_own_pending" on public.reservations
  for delete to authenticated
  using (user_id = auth.uid() and status = 'pending');

-- (f): disponibilidad por evento. security_invoker=off (default) a propósito:
-- agrega TODAS las reservas con privilegios del owner, pero solo expone
-- conteos agregados.
create or replace view public.event_availability as
select
  e.id as event_id,
  e.capacity,
  (e.capacity - coalesce(
    sum(r.quantity) filter (
      where r.status = 'confirmed'
        or (r.status = 'pending'
            and r.created_at > now() - interval '15 minutes')
    ), 0
  ))::integer as available
from public.events e
left join public.reservations r on r.event_id = e.id
group by e.id, e.capacity;

revoke all on public.event_availability from anon;
grant select on public.event_availability to authenticated;

-- (g): permite un seed idempotente (`on conflict (image_key) do nothing`).
-- unique permite múltiples NULL, así que no restringe eventos sin imagen.
alter table public.events
  drop constraint if exists events_image_key_key;
alter table public.events
  add constraint events_image_key_key unique (image_key);

