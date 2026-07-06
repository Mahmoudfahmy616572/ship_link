import { createClient } from 'npm:@supabase/supabase-js@2'

const PAYMOB_API_KEY = Deno.env.get('PAYMOB_API_KEY') ?? ''
const PAYMOB_INTEGRATION_ID = Deno.env.get('PAYMOB_INTEGRATION_ID') ?? ''
const PAYMOB_IFRAME_ID = Deno.env.get('PAYMOB_IFRAME_ID') ?? '1054329'
const PAYMOB_BASE = 'https://accept.paymob.com'
const SUPABASE_URL = Deno.env.get('SUPABASE_URL') ?? ''
const CALLBACK_URL = `${SUPABASE_URL}/functions/v1/paymob-callback`

Deno.serve(async (req) => {
  try {
    const { totalPrice, orderId, userId, paymentMethodToken, redirectUri } = await req.json()
    if (!totalPrice || !orderId || !userId || !paymentMethodToken) {
      return new Response(JSON.stringify({ error: 'Missing required fields' }), { status: 400 })
    }

    // Auth
    const authRes = await fetch(`${PAYMOB_BASE}/api/auth/tokens`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ api_key: PAYMOB_API_KEY }),
    })
    const authData = await authRes.json()
    const token = authData.token
    if (!token) {
      return new Response(JSON.stringify({ error: 'Failed to get Paymob token' }), { status: 500 })
    }

    // Create Paymob order
    const orderRes = await fetch(`${PAYMOB_BASE}/api/ecommerce/orders`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        auth_token: token,
        delivery_needed: 'false',
        amount_cents: Math.round(totalPrice * 100),
        currency: 'EGP',
        merchant_order_id: orderId,
        items: [],
      }),
    })
    const orderData = await orderRes.json()
    const paymobOrderId = orderData.id
    if (!paymobOrderId) {
      return new Response(JSON.stringify({ error: 'Failed to create Paymob order' }), { status: 500 })
    }

    // Get user email
    const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? ''
    const supabase = createClient(supabaseUrl, Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!)
    const { data: userData } = await supabase.from('profiles').select('email').eq('id', userId).maybeSingle()
    const userEmail = userData?.email ?? `${userId}@ship-link.app`

    // Payment key with saved card token
    const billingData = {
      apartment: 'N/A', email: userEmail, floor: 'N/A', first_name: 'User',
      street: 'N/A', building: 'N/A', phone_number: `01${String(Math.random()).slice(2, 11)}`,
      shipping_method: 'PKG', postal_code: 'N/A', city: 'N/A',
      country: 'EG', last_name: 'User', state: 'N/A',
    }
    const pkRes = await fetch(`${PAYMOB_BASE}/api/acceptance/payment_keys`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        auth_token: token,
        amount_cents: Math.round(totalPrice * 100),
        expiration: 3600,
        order_id: paymobOrderId,
        billing_data: billingData,
        currency: 'EGP',
        integration_id: Number(PAYMOB_INTEGRATION_ID),
        card_token: paymentMethodToken,
      }),
    })
    const pkData = await pkRes.json()
    const paymentKey = pkData.token
    if (!paymentKey) {
      return new Response(JSON.stringify({ error: 'Failed to get payment key' }), { status: 500 })
    }

    // Store paymob_order_id for callback matching
    await supabase.from('orders').update({ paymob_order_id: paymobOrderId }).eq('id', orderId)

    const callbackWithRedirect = redirectUri
      ? `${CALLBACK_URL}?redirect_uri=${encodeURIComponent(redirectUri)}`
      : CALLBACK_URL
    const url = `${PAYMOB_BASE}/api/acceptance/iframes/${PAYMOB_IFRAME_ID}?payment_token=${paymentKey}&callback=${encodeURIComponent(callbackWithRedirect)}`

    return new Response(JSON.stringify({ url, transactionId: paymobOrderId }), {
      headers: { 'Content-Type': 'application/json' },
    })
  } catch (e) {
    return new Response(JSON.stringify({ error: e.message }), { status: 500 })
  }
})
