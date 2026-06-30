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
