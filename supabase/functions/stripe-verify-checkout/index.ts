// Eventix — verifica el pago de una sesión de Stripe Checkout y CONFIRMA la
// reserva pendiente asociada (metadata.reservation_id) server-side con
// service role. verify_jwt = true.
//
// Idempotente: si la reserva ya estaba confirmada devuelve confirmed=true.
// Caso borde documentado: si el pending expiró (>15 min) y el cupo se
// revendió, el update no aplica y se devuelve confirmed=false — en un
// sistema real esto dispara un reembolso; aquí se informa al usuario.
import 'jsr:@supabase/functions-js/edge-runtime.d.ts';
import { createClient } from 'jsr:@supabase/supabase-js@2';

const STRIPE_SECRET_KEY = Deno.env.get('STRIPE_SECRET_KEY') ?? '';
const SUPABASE_URL = Deno.env.get('SUPABASE_URL') ?? '';
const SUPABASE_ANON_KEY = Deno.env.get('SUPABASE_ANON_KEY') ?? '';
const SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';

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

    const { sessionId } = await req.json();
    if (!sessionId) {
      return json({ error: 'sessionId requerido' }, 400);
    }

    const res = await fetch(
      `https://api.stripe.com/v1/checkout/sessions/${sessionId}`,
      { headers: { Authorization: `Bearer ${STRIPE_SECRET_KEY}` } },
    );
    const session = await res.json();
    if (!res.ok) {
      return json(
        { error: session?.error?.message ?? 'No se pudo verificar el pago' },
        400,
      );
    }

    // La sesión debe pertenecer al usuario que consulta.
    if (session?.metadata?.user_id !== userData.user.id) {
      return json({ error: 'Sesión no encontrada' }, 404);
    }

    const paid = session.payment_status === 'paid';
    const reservationId = session?.metadata?.reservation_id ?? '';
    let confirmed = false;

    if (paid && reservationId && SERVICE_ROLE_KEY) {
      // Confirmación server-side: el cliente NUNCA puede pasar una reserva
      // a 'confirmed' (lo bloquea el trigger); solo esta función.
      const admin = createClient(SUPABASE_URL, SERVICE_ROLE_KEY);
      const { data: updated, error: updErr } = await admin
        .from('reservations')
        .update({ status: 'confirmed' })
        .eq('id', reservationId)
        .eq('user_id', userData.user.id)
        .eq('status', 'pending')
        .select('id');
      if (updErr) {
        return json({ error: 'No se pudo confirmar la reserva' }, 500);
      }
      confirmed = (updated?.length ?? 0) > 0;

      if (!confirmed) {
        // Reintento idempotente: ¿ya estaba confirmada?
        const { data: existing } = await admin
          .from('reservations')
          .select('status')
          .eq('id', reservationId)
          .eq('user_id', userData.user.id)
          .maybeSingle();
        confirmed = existing?.status === 'confirmed';
      }
    }

    return json(
      {
        paid,
        confirmed,
        reservationId,
        paymentStatus: session.payment_status,
        status: session.status,
      },
      200,
    );
  } catch (e) {
    return json({ error: String(e) }, 500);
  }
});
