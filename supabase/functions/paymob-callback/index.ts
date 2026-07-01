import { createClient } from 'npm:@supabase/supabase-js@2'

const PAYMOB_HMAC = Deno.env.get('PAYMOB_HMAC') ?? ''

async function computeHmac(secret: string, data: string): Promise<string> {
  const key = await crypto.subtle.importKey(
    'raw',
    new TextEncoder().encode(secret),
    { name: 'HMAC', hash: 'SHA-512' },
    false,
    ['sign'],
  )
  const signature = await crypto.subtle.sign('HMAC', key, new TextEncoder().encode(data))
  return Array.from(new Uint8Array(signature)).map((b) => b.toString(16).padStart(2, '0')).join('')
}

function htmlPage(title: string, message: string, isSuccess: boolean) {
  return `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${title}</title>
  <style>
    body { font-family: Arial, sans-serif; display: flex; justify-content: center; align-items: center; min-height: 100vh; margin: 0; background: #f5f5f5; }
    .card { background: white; padding: 40px; border-radius: 16px; box-shadow: 0 2px 12px rgba(0,0,0,0.1); text-align: center; max-width: 400px; }
    .icon { font-size: 64px; margin-bottom: 16px; }
    h1 { margin: 0 0 8px; color: ${isSuccess ? '#10B981' : '#EF4444'}; }
    p { color: #6B7280; margin: 0 0 24px; }
    .btn { display: inline-block; padding: 12px 24px; border-radius: 8px; background: #2563EB; color: white; text-decoration: none; font-weight: 500; }
  </style>
</head>
<body>
  <div class="card">
    <div class="icon">${isSuccess ? '\u2705' : '\u274C'}</div>
    <h1>${title}</h1>
    <p>${message}</p>
    <a class="btn" href="javascript:window.close()">Close &amp; Return to App</a>
  </div>
</body>
</html>`
}

Deno.serve(async (req) => {
  try {
    const url = new URL(req.url)
    const supabase = createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!)
    let success = false
    let paymobOrderId: string | null = null

    if (req.method === 'GET') {
      success = url.searchParams.get('success') === 'true'
      paymobOrderId = url.searchParams.get('order') ?? url.searchParams.get('order_id')
      console.log('GET callback query params:', Object.fromEntries(url.searchParams.entries()))
    } else {
      const body = await req.json()
      const obj = body.obj ?? body

      const receivedHmac = obj.hmac ?? ''
      if (receivedHmac && PAYMOB_HMAC) {
        const expectedHmac = await computeHmac(PAYMOB_HMAC, JSON.stringify(obj))
        if (receivedHmac !== expectedHmac) {
          return new Response(JSON.stringify({ success: false, error: 'HMAC mismatch' }), {
            headers: { 'Content-Type': 'application/json' },
          })
        }
      }

      success = obj.success === true
      paymobOrderId = obj.order?.id?.toString() ?? obj.order_id?.toString()
    }

    if (!paymobOrderId) {
      if (req.method === 'GET') {
        return new Response(htmlPage('Error', 'Missing order reference. Please return to the app.', false), {
          headers: { 'Content-Type': 'text/html; charset=utf-8' },
        })
      }
      return new Response(JSON.stringify({ success: false, error: 'Missing order id' }), {
        headers: { 'Content-Type': 'application/json' },
      })
    }

    const { data: orders } = await supabase
      .from('orders')
      .select('id')
      .eq('paymob_order_id', Number(paymobOrderId))
      .limit(1)

    if (!orders || orders.length === 0) {
      if (req.method === 'GET') {
        return new Response(htmlPage('Error', 'Order not found. Please return to the app.', false), {
          headers: { 'Content-Type': 'text/html; charset=utf-8' },
        })
      }
      return new Response(JSON.stringify({ success: false, error: 'Order not found' }), {
        headers: { 'Content-Type': 'application/json' },
      })
    }

    const orderId = orders[0].id

    if (success) {
      await supabase
        .from('orders')
        .update({ status: 'confirmed', paid_at: new Date().toISOString() })
        .eq('id', orderId)
    } else {
      await supabase
        .from('orders')
        .update({ status: 'payment_failed' })
        .eq('id', orderId)
    }

    if (req.method === 'GET') {
      return new Response(
        htmlPage(
          success ? 'Payment Successful!' : 'Payment Failed',
          success ? 'Your payment has been processed. You can close this tab and return to the app.' : 'There was an issue processing your payment. Please try again.',
          success,
        ),
        { headers: { 'Content-Type': 'text/html; charset=utf-8' } },
      )
    }

    return new Response(JSON.stringify({ success }), {
      headers: { 'Content-Type': 'application/json' },
    })
  } catch (e) {
    return new Response(JSON.stringify({ success: false, error: e.message }), {
      headers: { 'Content-Type': 'application/json' },
    })
  }
})
