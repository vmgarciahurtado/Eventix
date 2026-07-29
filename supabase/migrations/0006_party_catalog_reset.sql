-- 0006 — Reinicio del catálogo con identidad de vida nocturna.
--
-- El catálogo original mezclaba maratones, expos y cumbres técnicas, que no
-- encajan con la identidad de la app (negro + neón, fiestas). Aquí se cambia
-- por categorías y eventos de noche.
--
-- Destructivo a propósito: borra reservas, tickets y el catálogo previo para
-- poder recorrer el flujo completo desde el registro. Los usuarios de
-- `auth.users` se borran aparte (ver nota al final).

-- ---------------------------------------------------------------------------
-- Limpieza
-- ---------------------------------------------------------------------------
-- Los tickets y las reservas caen en cascada al borrar eventos, pero se
-- vacían explícitamente para que el orden no dependa de las FK.
delete from public.tickets;
delete from public.reservations;
delete from public.events;

-- ---------------------------------------------------------------------------
-- Categorías de vida nocturna
-- ---------------------------------------------------------------------------
-- Se reemplazan las anteriores. `slug` es la clave estable para la identidad
-- visual; `name` es solo lo que se muestra.
delete from public.categories;
insert into public.categories (id, name, slug) values
  (1, 'Reggaetón', 'reggaeton'),
  (2, 'Electrónica', 'electronica'),
  (3, 'Salsa', 'salsa'),
  (4, 'Rooftop', 'rooftop'),
  (5, 'After', 'after')
on conflict (id) do update set name = excluded.name, slug = excluded.slug;

insert into public.cities (id, name) values
  (1, 'Bogotá'),
  (2, 'Medellín'),
  (3, 'Cali'),
  (4, 'Barranquilla')
on conflict (id) do nothing;

-- ---------------------------------------------------------------------------
-- Eventos
-- ---------------------------------------------------------------------------
-- Fechas futuras y escalonadas para que el listado (ordenado por `starts_at`)
-- tenga variedad. Se deja un evento gratuito para probar el flujo sin pasar
-- por Stripe.
--
-- La hora se fija con `(current_date + N) + time` en zona Bogotá, NO con
-- `now() + interval 'N hours'`: eso último suma horas a la hora en que corre
-- la migración y produce fiestas a las 6 de la mañana.
insert into public.events
  (title, description, category_id, city_id, starts_at, price, capacity,
   image_key)
select
  v.title, v.description, v.category_id, v.city_id,
  ((current_date + v.dias)::timestamp + v.hora) at time zone 'America/Bogota',
  v.price, v.capacity, v.image_key
from (values
  ('Warm Up Gratis',
   'El calentamiento de la temporada. Entrada libre para estrenar la pista '
   'nueva: cupo limitado y sin reventa.',
   1, 1, 2, time '21:00', 0, 120, 'warm_up'),
  ('The Biggest Latino Party',
   'La noche más grande de reggaetón y perreo en el centro de Bogotá. Tres '
   'pistas, cabina abierta hasta el amanecer.',
   1, 1, 3, time '23:00', 85000, 400, 'latino_party'),
  ('Sunset Rooftop Session',
   'Atardecer en la terraza con house melódico, coctelería de autor y la '
   'ciudad de fondo.',
   4, 2, 4, time '18:00', 70000, 150, 'sunset_rooftop'),
  ('Reggaetón Nights',
   'Los clásicos que suenan desde 2005 mezclados con lo que está pegando '
   'ahora. Dress code: como quieras.',
   1, 2, 5, time '22:00', 60000, 300, 'reggaeton_nights'),
  ('Salsa Brava en Vivo',
   'Orquesta completa y pista de baile de verdad. La salsa como se toca en '
   'Cali, sin concesiones.',
   3, 3, 6, time '21:00', 55000, 250, 'salsa_brava'),
  ('Techno Warehouse',
   'Bodega, humo y un sistema de sonido que se siente en el pecho. Line-up '
   'de electrónica con invitados internacionales.',
   2, 1, 8, time '23:30', 120000, 600, 'techno_warehouse'),
  ('Carnaval After Party',
   'Cuando todo cierra, esto abre. Champeta, afrobeat y tambores hasta que '
   'salga el sol.',
   5, 4, 10, time '02:00', 45000, 350, 'carnaval_after'),
  ('Open Air Electrónica',
   'Fiesta al aire libre con visuales y dos escenarios. Trae chaqueta, la '
   'madrugada pega.',
   2, 2, 12, time '20:00', 95000, 800, 'open_air')
) as v(title, description, category_id, city_id, dias, hora, price, capacity,
       image_key);

-- ---------------------------------------------------------------------------
-- Nota sobre los usuarios
-- ---------------------------------------------------------------------------
-- `auth.users` no se toca desde una migración: pertenece al esquema de Auth y
-- borrarlo desde aquí acopla el esquema de la app al de Supabase. Para
-- empezar de cero con el registro, bórralos desde el dashboard
-- (Authentication → Users) o con la Admin API. `profiles` cae en cascada.
