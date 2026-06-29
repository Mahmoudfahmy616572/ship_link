import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

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

serve(async (req) => {
  try {
    const url = new URL(req.url)
    const supabase = createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!)
    let success = false
    let paymobOrderId: string | null = null

    if (req.method === 'GET') {
      // Redirect from Paymob after payment (WebView lands here)
      success = url.searchParams.get('success') === 'true'
      paymobOrderId = url.searchParams.get('order') ?? url.searchParams.get('order_id')
    } else {
      // Webhook from Paymob server
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
      return new Response(JSON.stringify({ success: true }), {
        headers: { 'Content-Type': 'application/json' },
      })
    } else {
      await supabase
        .from('orders')
        .update({ status: 'payment_failed' })
        .eq('id', orderId)
      return new Response(JSON.stringify({ success: false }), {
        headers: { 'Content-Type': 'application/json' },
      })
    }
  } catch (e) {
    return new Response(JSON.stringify({ success: false, error: e.message }), {
      headers: { 'Content-Type': 'application/json' },
    })
  }
})
