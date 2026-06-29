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
