import { createClient } from 'npm:@supabase/supabase-js@2'

const PAYMOB_HMAC = Deno.env.get('PAYMOB_HMAC') ?? ''
const PAYMOB_API_KEY = Deno.env.get('PAYMOB_API_KEY') ?? ''
const PAYMOB_BASE = 'https://accept.paymob.com'

async function paymobAuth(): Promise<string | null> {
  if (!PAYMOB_API_KEY) return null
  try {
    const res = await fetch(`${PAYMOB_BASE}/api/auth/tokens`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ api_key: PAYMOB_API_KEY }),
    })
    const data = await res.json()
    return data.token ?? null
  } catch (e) {
    console.log('paymobAuth error:', e instanceof Error ? e.message : String(e))
    return null
  }
}

async function fetchPaymobTransaction(txnId: string): Promise<{ cardToken: string | null; lastFour: string | null; cardBrand: string | null; rawResponse: string | null }> {
  for (let i = 0; i < 5; i++) {
    try {
      const token = await paymobAuth()
      if (!token) { console.log(`fetchPaymob: auth failed (attempt ${i + 1})`); continue }

      const res = await fetch(`${PAYMOB_BASE}/api/acceptance/transactions/${txnId}`, {
        headers: { Authorization: `Bearer ${token}` },
      })
      const rawText = await res.text()
      console.log(`fetchPaymob: attempt ${i + 1} status=${res.status} body=${rawText.slice(0, 500)}`)

      let data: Record<string, unknown>
      try { data = JSON.parse(rawText) } catch {
        console.log(`fetchPaymob: invalid JSON (attempt ${i + 1})`)
        if (i < 4) await new Promise(r => setTimeout(r, 2000 * (i + 1)))
        continue
      }

      const cardToken = (data.card_token ?? data.token ?? data.card_token_id ?? null) as string | null
      const lastFour = (data.card_last_four_digits ?? (data.source_data as Record<string, unknown> | undefined)?.pan ?? null) as string | null
      const cardBrand = (data.card_subtype ?? (data.source_data as Record<string, unknown> | undefined)?.sub_type ?? null) as string | null

      if (cardToken) {
        console.log(`fetchPaymob: SUCCESS cardToken=${cardToken} lastFour=${lastFour} brand=${cardBrand}`)
        return { cardToken, lastFour, cardBrand, rawResponse: rawText.slice(0, 1000) }
      }

      console.log(`fetchPaymob: no cardToken yet (attempt ${i + 1})`)
      if (i < 4) await new Promise(r => setTimeout(r, 2000 * (i + 1)))
    } catch (e) {
      console.log(`fetchPaymob: error (attempt ${i + 1}):`, e instanceof Error ? e.message : String(e))
      if (i < 4) await new Promise(r => setTimeout(r, 2000 * (i + 1)))
    }
  }
  console.log('fetchPaymob: EXHAUSTED all retries, returning null')
  return { cardToken: null, lastFour: null, cardBrand: null, rawResponse: null }
}

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
    let cardToken: string | null = null
    let lastFour: string | null = null
    let cardBrand: string | null = null

    const txnId = url.searchParams.get('id') ?? null
    let redirectUri: string | null = null

    if (req.method === 'GET') {
      success = url.searchParams.get('success') === 'true'
      paymobOrderId = url.searchParams.get('order') ?? url.searchParams.get('order_id')
      cardToken = url.searchParams.get('card_token') ?? url.searchParams.get('token') ?? null
      lastFour = url.searchParams.get('card_last_four_digits') ?? url.searchParams.get('card_last_four') ?? url.searchParams.get('source_data.pan') ?? null
      cardBrand = url.searchParams.get('card_subtype') ?? url.searchParams.get('source_data.sub_type') ?? null
      redirectUri = url.searchParams.get('redirect_uri') ?? null
      const allParams = Object.fromEntries(url.searchParams.entries())
      console.log('GET callback params (keys):', Object.keys(allParams).join(', '))
      console.log('Has card_token:', 'card_token' in allParams, 'value:', allParams.card_token ?? 'NOT_PRESENT')
      console.log('merchant_order_id:', allParams.merchant_order_id ?? 'NOT_PRESENT')
      console.log('source_data.pan:', allParams['source_data.pan'] ?? 'NOT_PRESENT')
      console.log('id (txnId):', txnId)
      console.log('order:', paymobOrderId)

      // Fallback: if card_token missing, fetch from Paymob API using transaction ID
      if (!cardToken && txnId) {
        console.log('Paymob API fallback: card_token missing from GET params, fetching for txn:', txnId)
        console.log('Paymob API fallback: all GET params:', JSON.stringify(allParams))
        const result = await fetchPaymobTransaction(txnId)
        if (result.cardToken) {
          cardToken = result.cardToken
          lastFour = result.lastFour ?? lastFour
          cardBrand = result.cardBrand ?? cardBrand
          console.log('Paymob API fallback SUCCESS: cardToken=' + result.cardToken + ' lastFour=' + result.lastFour + ' brand=' + result.cardBrand)
        } else {
          console.log('Paymob API fallback FAILED: rawResponse=' + (result.rawResponse ?? 'null'))
        }
      } else if (!cardToken && !txnId) {
        console.log('Paymob API fallback: no card_token AND no txnId')
      }
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
      cardToken = obj.card_token ?? null
      lastFour = obj.card_last_four_digits ?? obj.source_data?.pan ?? null
      cardBrand = obj.card_subtype ?? obj.source_data?.sub_type ?? null
      redirectUri = obj.redirect_uri ?? null
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

    // Try lookup by paymob_order_id first, then by merchant_order_id (local order ID)
    let { data: orders, error: lookupError } = await supabase
      .from('orders')
      .select('id, status, user_id')
      .eq('paymob_order_id', Number(paymobOrderId))
      .limit(1)

    if (!orders || orders.length === 0) {
      const merchantIdStr = url.searchParams.get('merchant_order_id') ?? null
      if (merchantIdStr) {
        console.log('paymob_order_id lookup failed, trying merchant_order_id:', merchantIdStr)
        const result = await supabase
          .from('orders')
          .select('id, status, user_id')
          .eq('id', Number(merchantIdStr))
          .limit(1)
        orders = result.data
        lookupError = result.error
        if (orders && orders.length > 0) {
          console.log('Found order by merchant_order_id:', orders[0].id)
        }
      }
    }

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

    const order = orders[0]
    const orderId = order.id
    const isTokenizing = order.status === 'tokenizing'

    if (success) {
      if (isTokenizing) {
        // Card tokenization flow — save card and mark order as "paid" (1 EGP authorization)
        await supabase.from('orders').update({
          status: 'confirmed',
          paid_at: new Date().toISOString(),
        }).eq('id', orderId)

        if (lastFour) {
          const userId = order.user_id
          const localToken = cardToken ?? crypto.randomUUID()
          const { error: insertError } = await supabase.from('payment_methods').insert({
            user_id: userId,
            paymob_token: localToken,
            last_four: lastFour.slice(-4),
            card_brand: cardBrand ?? '',
            is_default: false,
          })
          if (insertError) {
            console.log('payment_methods insert error:', insertError)
            await supabase.from('orders').update({ payment_error: 'insert_failed: ' + insertError.message }).eq('id', orderId)
          } else {
            console.log('payment_methods inserted OK for user:', userId, 'token:', localToken.slice(0, 8) + '...')
          }
        } else {
          console.log('SKIP payment_methods insert: no lastFour available')
          await supabase.from('orders').update({ payment_error: 'missing_card_data: no lastFour' }).eq('id', orderId)
        }
      } else {
        await supabase
          .from('orders')
          .update({ status: 'pending', paid_at: new Date().toISOString() })
          .eq('id', orderId)

        if (lastFour && order.user_id) {
          const localToken = cardToken ?? crypto.randomUUID()
          const { error: insertError } = await supabase.from('payment_methods').insert({
            user_id: order.user_id,
            paymob_token: localToken,
            last_four: lastFour.slice(-4),
            card_brand: cardBrand ?? '',
            is_default: false,
          })
          if (insertError) console.log('payment_methods insert error (checkout):', insertError)
          else console.log('payment_methods inserted (checkout) for user:', order.user_id)
        } else {
          console.log('No card data to save during checkout: lastFour=' + (lastFour ?? 'null'))
        }
      }
    } else {
      if (isTokenizing) {
        await supabase.from('orders').update({ status: 'cancelled' }).eq('id', orderId)
      } else {
        await supabase
          .from('orders')
          .update({ status: 'payment_failed' })
          .eq('id', orderId)
      }
    }

    if (req.method === 'GET') {
      if (redirectUri) {
        const separator = redirectUri.includes('?') ? '&' : '?'
        const redirectTarget = `${redirectUri}${separator}success=${success}&orderId=${orderId}`
        return new Response(null, { status: 302, headers: { Location: redirectTarget } })
      }
      return new Response(
        htmlPage(
          success ? 'Payment Successful!' : 'Payment Failed',
          success
            ? (isTokenizing ? 'Card saved successfully!' : 'Your payment has been processed.')
            : 'There was an issue processing your payment. Please try again.',
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
