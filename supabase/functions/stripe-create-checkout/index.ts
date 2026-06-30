// Eventix — crea una sesión de Stripe Checkout para pagar una reserva.
// verify_jwt = true: solo usuarios autenticados. El precio se toma de la BD
// (no se confía en el cliente). Si wantInvoice es true, Stripe genera y envía
// la factura al correo del usuario (invoice_creation).
import 'jsr:@supabase/functions-js/edge-runtime.d.ts';
import { createClient } from 'jsr:@supabase/supabase-js@2';

const STRIPE_SECRET_KEY = Deno.env.get('STRIPE_SECRET_KEY') ?? '';
const SUPABASE_URL = Deno.env.get('SUPABASE_URL') ?? '';
const SUPABASE_ANON_KEY = Deno.env.get('SUPABASE_ANON_KEY') ?? '';

// Moneda del catálogo (precios en COP). COP usa unidad menor x100.
const CURRENCY = 'cop';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type',
};

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }
  try {
    if (!STRIPE_SECRET_KEY) {
      return json({ error: 'Falta configurar STRIPE_SECRET_KEY' }, 500);
    }

    const authHeader = req.headers.get('Authorization') ?? '';
    const token = authHeader.replace('Bearer ', '');
    const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
      global: { headers: { Authorization: authHeader } },
    });

    const { data: userData, error: userErr } = await supabase.auth.getUser(
      token,
    );
    if (userErr || !userData.user) {
      return json({ error: 'No autenticado' }, 401);
    }
    const user = userData.user;

    const payload = await req.json();
    const eventId = String(payload.eventId ?? '');
    const quantity = Math.max(1, parseInt(String(payload.quantity ?? 1), 10));
    const wantInvoice = payload.wantInvoice === true;

    // Precio autoritativo desde la BD (RLS: lectura autenticada).
    const { data: event, error: evErr } = await supabase
      .from('events')
      .select('id, title, price')
      .eq('id', eventId)
      .single();
    if (evErr || !event) {
      return json({ error: 'Evento no encontrado' }, 404);
    }

    const unitAmount = Math.round(Number(event.price)) * 100;
    if (unitAmount <= 0) {
      return json({ error: 'Este evento es gratuito, no requiere pago.' }, 400);
    }

    const returnBase = `${SUPABASE_URL}/functions/v1/stripe-return`;
    const params = new URLSearchParams();
    params.set('mode', 'payment');
    params.set('success_url', `${returnBase}?status=success`);
    params.set('cancel_url', `${returnBase}?status=cancel`);
    params.set('customer_email', user.email ?? '');
    params.set('line_items[0][quantity]', String(quantity));
    params.set('line_items[0][price_data][currency]', CURRENCY);
    params.set('line_items[0][price_data][unit_amount]', String(unitAmount));
    params.set('line_items[0][price_data][product_data][name]', event.title);
    if (wantInvoice) {
      params.set('invoice_creation[enabled]', 'true');
    }
    params.set('metadata[user_id]', user.id);
    params.set('metadata[event_id]', eventId);
    params.set('metadata[quantity]', String(quantity));

    const res = await fetch('https://api.stripe.com/v1/checkout/sessions', {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${STRIPE_SECRET_KEY}`,
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: params.toString(),
    });
    const session = await res.json();
    if (!res.ok) {
      return json(
        { error: session?.error?.message ?? 'No se pudo crear el pago' },
        400,
      );
    }

    return json({ url: session.url, sessionId: session.id }, 200);
  } catch (e) {
    return json({ error: String(e) }, 500);
  }
});
