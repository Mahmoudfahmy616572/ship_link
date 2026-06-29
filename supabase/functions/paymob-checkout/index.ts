import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const PAYMOB_API_KEY = Deno.env.get('PAYMOB_API_KEY') ?? ''
const PAYMOB_INTEGRATION_ID = Deno.env.get('PAYMOB_INTEGRATION_ID') ?? ''

serve(async (req) => {
  try {
    const { totalPrice, orderId, userId } = await req.json()
    if (!totalPrice || !orderId || !userId) {
      return new Response(JSON.stringify({ error: 'Missing required fields' }), { status: 400 })
    }

    // 1. Auth
    const authRes = await fetch('https://accept.paymob.com/api/auth/tokens', {
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
    const orderRes = await fetch('https://accept.paymob.com/api/ecommerce/orders', {
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

    const projectRef = supabaseUrl.replace('https://', '').replace('.supabase.co', '')
    const callbackUrl = `https://${projectRef}.supabase.co/functions/v1/paymob-callback`

    const billingData = {
      apartment: 'N/A', email: userEmail, floor: 'N/A', first_name: 'User',
      street: 'N/A', building: 'N/A', phone_number: 'N/A',
      shipping_method: 'PKG', postal_code: 'N/A', city: 'N/A',
      country: 'EG', last_name: 'User', state: 'N/A',
    }
    const pkRes = await fetch('https://accept.paymob.com/api/acceptance/payment_keys', {
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
        lock_order_when_paid: 'true',
      }),
    })
    const pkData = await pkRes.json()
    const paymentKey = pkData.token
    if (!paymentKey) {
      return new Response(JSON.stringify({ error: 'Failed to get payment key', details: pkData }), { status: 500 })
    }

    // 4. Build checkout URL with return_url so Paymob redirects to our callback
    const url = `https://accept.paymob.com/api/acceptance/payments/payment?payment_token=${paymentKey}&return_url=${encodeURIComponent(callbackUrl)}`

    // 5. Store paymob_order_id on our order for callback matching
    await supabase.from('orders').update({ paymob_order_id: paymobOrderId }).eq('id', orderId)

    return new Response(JSON.stringify({ url, transactionId: paymobOrderId }), {
      headers: { 'Content-Type': 'application/json' },
    })
  } catch (e) {
    return new Response(JSON.stringify({ error: e.message }), { status: 500 })
  }
})
