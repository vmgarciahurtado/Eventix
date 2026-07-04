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
