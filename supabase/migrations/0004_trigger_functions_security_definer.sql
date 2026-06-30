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
