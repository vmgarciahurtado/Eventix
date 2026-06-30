// Eventix — página de retorno de Stripe Checkout (pública, verify_jwt = false).
// Stripe redirige aquí tras el pago. Es solo informativa: la app verifica el
// pago real con stripe-verify-checkout al volver al primer plano.
//
// Diseño "a prueba de balas": texto solo-ASCII (sin acentos ni emoji) y
// estilos inline. Así se ve bien en un navegador y, si algún middlebox la
// entrega como text/plain, igual se lee limpia (sin mojibake ni CSS suelto).
import 'jsr:@supabase/functions-js/edge-runtime.d.ts';

Deno.serve((req: Request) => {
  const url = new URL(req.url);
  const ok = (url.searchParams.get('status') ?? 'success') === 'success';

  const title = ok ? 'Pago completado' : 'Pago cancelado';
  const message = ok
    ? 'Vuelve a la app de Eventix para ver tu reserva.'
    : 'Puedes volver a la app e intentarlo de nuevo.';
  const accent = ok ? '#16A34A' : '#D97706';

  const body =
    '<div style="background:#fff;color:#101828;border-radius:20px;' +
    'padding:40px 28px;max-width:380px;width:100%;text-align:center;' +
    'box-shadow:0 10px 40px rgba(16,24,40,.2)">' +
    `<div style="font-size:44px;font-weight:800;color:${accent}">` +
    `${ok ? 'OK' : '!'}</div>` +
    `<h1 style="margin:14px 0 8px;font-size:22px">Eventix</h1>` +
    `<h2 style="margin:0 0 8px;font-size:18px;color:${accent}">${title}</h2>` +
    `<p style="margin:0;color:#475467;font-size:15px;line-height:1.5">` +
    `${message}</p></div>`;

  const html =
    '<!doctype html><html lang="es"><head><meta charset="utf-8">' +
    '<meta name="viewport" content="width=device-width, initial-scale=1">' +
    '<title>Eventix</title></head>' +
    '<body style="margin:0;min-height:100vh;display:flex;' +
    'align-items:center;justify-content:center;' +
    "font-family:-apple-system,'Segoe UI',Roboto,Arial,sans-serif;" +
    'background:#4F46E5;padding:24px">' +
    body +
    '</body></html>';

  return new Response(html, {
    status: 200,
    headers: { 'Content-Type': 'text/html; charset=utf-8' },
  });
});
