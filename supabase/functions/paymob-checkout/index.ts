import { createClient } from 'npm:@supabase/supabase-js@2'

const PAYMOB_API_KEY = Deno.env.get('PAYMOB_API_KEY') ?? ''
const PAYMOB_INTEGRATION_ID = Deno.env.get('PAYMOB_INTEGRATION_ID') ?? ''
const PAYMOB_BASE = 'https://accept.paymob.com'

Deno.serve(async (req) => {
  try {
    const { totalPrice, orderId, userId } = await req.json()
    if (!totalPrice || !orderId || !userId) {
      return new Response(JSON.stringify({ error: 'Missing required fields' }), { status: 400 })
    }

    // 1. Auth
    const authRes = await fetch(`${PAYMOB_BASE}/api/auth/tokens`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ api_key: PAYMOB_API_KEY }),
    })
    const authData = await authRes.json()
    const token = authData.token
    if (!token) {
      return new Response(JSON.stringify({ error: 'Failed to get Paymob token', details: authData }), { status: 500 })
    }

    // 2. Create order on Paymob
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
      return new Response(JSON.stringify({ error: 'Failed to create Paymob order', details: orderData }), { status: 500 })
    }

    // 3. Fetch user email for Paymob billing data
    const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? ''
    const supabase = createClient(supabaseUrl, Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!)
    const { data: userData } = await supabase.from('profiles').select('email').eq('id', userId).maybeSingle()
    const userEmail = userData?.email ?? `${userId}@ship-link.app`

    // 4. Payment key
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
      }),
    })
    const pkData = await pkRes.json()
    const paymentKey = pkData.token
    if (!paymentKey) {
      return new Response(JSON.stringify({ error: 'Failed to get payment key', details: pkData }), { status: 500 })
    }

    // 5. Build iframe URL
    const url = `${PAYMOB_BASE}/api/acceptance/iframes/1054329?payment_token=${paymentKey}`

    // 6. Store paymob_order_id for callback matching
    await supabase.from('orders').update({ paymob_order_id: paymobOrderId }).eq('id', orderId)

    return new Response(JSON.stringify({ url, transactionId: paymobOrderId }), {
      headers: { 'Content-Type': 'application/json' },
    })
  } catch (e) {
    return new Response(JSON.stringify({ error: e.message }), { status: 500 })
  }
})
