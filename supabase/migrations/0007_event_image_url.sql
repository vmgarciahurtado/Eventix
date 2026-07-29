-- ---------------------------------------------------------------------------
-- 0007 — La imagen del evento pasa a ser un dato, no un asset
-- ---------------------------------------------------------------------------
-- `image_key` apuntaba a `assets/images/event_<key>.jpg`, archivos que nunca
-- existieron: el catálogo entero se veía con el degradado de respaldo. Con una
-- URL en la base, la imagen la manda el backend y la app solo la muestra.
--
-- Las URLs son de Unsplash (hotlink permitido por su licencia). En producción
-- lo natural es un bucket de Supabase Storage; el tipo de dato no cambia.

alter table public.events
  add column if not exists image_url text;

update public.events e
   set image_url = v.url
  from (values
    ('warm_up',
     'https://images.unsplash.com/photo-1720623784273-f9388b9aa535'),
    ('latino_party',
     'https://images.unsplash.com/photo-1574155376612-bfa4ed8aabfd'),
    ('sunset_rooftop',
     'https://images.unsplash.com/photo-1611244806964-91d204d4a2a7'),
    ('reggaeton_nights',
     'https://images.unsplash.com/photo-1545128485-c400e7702796'),
    ('salsa_brava',
     'https://images.unsplash.com/photo-1709131518045-0aa4d3b90e7c'),
    ('techno_warehouse',
     'https://images.unsplash.com/photo-1578736641330-3155e606cd40'),
    ('carnaval_after',
     'https://images.unsplash.com/photo-1687511844598-165c1fc387cc'),
    ('open_air',
     'https://images.unsplash.com/photo-1544785316-6e58aed68a50')
  ) as v(image_key, base)
 cross join lateral (
    select v.base || '?w=900&q=70&auto=format&fit=crop' as url
 ) as u(url)
 where e.image_key = v.image_key;

-- El unique de `image_key` existía para permitir seeds idempotentes; cae con
-- la columna. Los seeds nuevos se identifican por `id` (ver 0006).
alter table public.events
  drop constraint if exists events_image_key_key;

alter table public.events
  drop column if exists image_key;
