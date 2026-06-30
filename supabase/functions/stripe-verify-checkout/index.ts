// Eventix — verifica el estado de pago de una sesión de Stripe Checkout.
// verify_jwt = true. Confirma además que la sesión pertenece al usuario
// (metadata.user_id) antes de devolver el estado.
import 'jsr:@supabase/functions-js/edge-runtime.d.ts';
import { createClient } from 'jsr:@supabase/supabase-js@2';

const STRIPE_SECRET_KEY = Deno.env.get('STRIPE_SECRET_KEY') ?? '';
const SUPABASE_URL = Deno.env.get('SUPABASE_URL') ?? '';
const SUPABASE_ANON_KEY = Deno.env.get('SUPABASE_ANON_KEY') ?? '';

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

    return json(
      {
        paid: session.payment_status === 'paid',
        paymentStatus: session.payment_status,
        status: session.status,
      },
      200,
    );
  } catch (e) {
    return json({ error: String(e) }, 500);
  }
});
