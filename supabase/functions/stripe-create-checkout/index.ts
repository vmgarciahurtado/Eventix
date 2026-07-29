// Eventix — crea una sesión de Stripe Checkout para pagar una reserva
// PENDIENTE ya creada (flujo reservar-primero → pagar → confirmar).
// verify_jwt = true: solo usuarios autenticados.
//
// El cliente envía reservationId + wantInvoice. Cantidad, evento y precio se
// leen de la BD (no se confía en el cliente): la reserva se consulta con el
// token del usuario (RLS garantiza que sea suya) y el precio del evento es
// autoritativo. La sesión lleva reservation_id en metadata para que
// `stripe-verify-checkout` confirme esa reserva server-side.
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

/// Responde con el error de usuario y NO se traga la causa: la escribe en los
/// logs de la función y la adjunta como `detail`. Sin esto, una denegación de
/// RLS, una columna inexistente y un "cero filas" son indistinguibles.
function fail(
  message: string,
  status: number,
  cause?: { message?: string; code?: string; details?: string } | null,
): Response {
  if (cause) {
    console.error(`${message} ->`, JSON.stringify(cause));
  }
  return json(
    cause ? { error: message, detail: cause.message, code: cause.code } : {
      error: message,
    },
    status,
  );
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
    const reservationId = String(payload.reservationId ?? '');
    const wantInvoice = payload.wantInvoice === true;
    if (!reservationId) {
      return json({ error: 'reservationId requerido' }, 400);
    }

    // La RLS limita la consulta a reservas del propio usuario.
    const { data: reservation, error: resErr } = await supabase
      .from('reservations')
      .select('id, event_id, quantity, status')
      .eq('id', reservationId)
      .single();
    if (resErr || !reservation) {
      return fail('Reserva no encontrada', 404, resErr);
    }
    if (reservation.status !== 'pending') {
      return json({ error: 'La reserva ya fue procesada' }, 409);
    }

    // Precio autoritativo desde la BD. Usamos service_role para garantizar lectura.
    const supabaseAdmin = createClient(
      SUPABASE_URL,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    );
    const { data: event, error: evErr } = await supabaseAdmin
      .from('events')
      .select('id, title, price')
      .eq('id', reservation.event_id)
      .single();
    if (evErr || !event) {
      return fail('Evento no encontrado', 404, { 
        message: evErr?.message, 
        details: evErr?.details, 
        code: evErr?.code,
        debug_reservation_event_id: reservation.event_id,
        debug_reservation_full: reservation
      } as any);
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
    params.set('line_items[0][quantity]', String(reservation.quantity));
    params.set('line_items[0][price_data][currency]', CURRENCY);
    params.set('line_items[0][price_data][unit_amount]', String(unitAmount));
    params.set('line_items[0][price_data][product_data][name]', event.title);
    if (wantInvoice) {
      params.set('invoice_creation[enabled]', 'true');
    }
    params.set('metadata[user_id]', user.id);
    params.set('metadata[reservation_id]', reservation.id);
    params.set('metadata[event_id]', event.id);
    params.set('metadata[quantity]', String(reservation.quantity));

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
