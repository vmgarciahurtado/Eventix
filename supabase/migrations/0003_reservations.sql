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
