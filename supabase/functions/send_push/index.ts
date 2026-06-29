import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const SERVICE_ACCOUNT_JSON = Deno.env.get('FIREBASE_SERVICE_ACCOUNT') ?? ''
const FCM_SERVER_KEY = Deno.env.get('FCM_SERVER_KEY') ?? ''

serve(async (req) => {
  try {
    const body = await req.json()
    // Handle both direct invoke and Supabase Webhook payload
    const payload = body.record ?? body
    const userId = payload.user_id ?? payload.userId
    const title = payload.title
    const innerBody = payload.body
    const type = payload.type ?? 'general'

    if (!userId || !title || !innerBody) {
      return new Response(JSON.stringify({ error: 'Missing fields' }), { status: 400 })
    }

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    )

    const { data: profile } = await supabase
      .from('profiles')
      .select('fcm_token')
      .eq('id', userId)
      .maybeSingle()

    const token = profile?.fcm_token
    if (!token) {
      return new Response(JSON.stringify({ error: 'No FCM token' }), { status: 200 })
    }

    // Try FCM v1 with service account first, fallback to legacy
    let fcmRes
    let result

    if (SERVICE_ACCOUNT_JSON) {
      const sa = JSON.parse(SERVICE_ACCOUNT_JSON)
      const accessToken = await getAccessToken(sa)
      fcmRes = await fetch(`https://fcm.googleapis.com/v1/projects/${sa.project_id}/messages:send`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${accessToken}`,
        },
        body: JSON.stringify({
          message: {
            token,
            notification: { title, body: innerBody },
            data: { type, userId },
          },
        }),
      })
      result = await fcmRes.json()
    } else if (FCM_SERVER_KEY) {
      fcmRes = await fetch('https://fcm.googleapis.com/fcm/send', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `key=${FCM_SERVER_KEY}`,
        },
        body: JSON.stringify({
          to: token,
          notification: { title, body: innerBody },
          data: { type, userId },
        }),
      })
      result = await fcmRes.json()
    } else {
      return new Response(JSON.stringify({ error: 'No FCM credentials configured' }), { status: 500 })
    }

    return new Response(JSON.stringify(result), {
      headers: { 'Content-Type': 'application/json' },
    })
  } catch (e) {
    return new Response(JSON.stringify({ error: e.message }), { status: 500 })
  }
})

async function getAccessToken(sa: Record<string, string>): Promise<string> {
  const header = { alg: 'RS256', typ: 'JWT' }
  const now = Math.floor(Date.now() / 1000)
  const payload = {
    iss: sa.client_email,
    scope: 'https://www.googleapis.com/auth/firebase.messaging',
    aud: 'https://oauth2.googleapis.com/token',
    exp: now + 3600,
    iat: now,
  }

  const b64 = (obj: unknown) =>
    btoa(JSON.stringify(obj))
      .replace(/=/g, '').replace(/\+/g, '-').replace(/\//g, '_')

  const signatureInput = `${b64(header)}.${b64(payload)}`

  const keyData = pemToBinary(sa.private_key)
  const key = await crypto.subtle.importKey(
    'pkcs8',
    keyData,
    { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
    false,
    ['sign'],
  )

  const sig = await crypto.subtle.sign(
    { name: 'RSASSA-PKCS1-v1_5' },
    key,
    new TextEncoder().encode(signatureInput),
  )

  const jwt = `${signatureInput}.${b64(new Uint8Array(sig))}`

  const res = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
      assertion: jwt,
    }),
  })

  const data = await res.json()
  return data.access_token
}

function pemToBinary(pem: string): ArrayBuffer {
  const b64 = pem
    .replace(/-----BEGIN .*-----/g, '')
    .replace(/-----END .*-----/g, '')
    .replace(/\s/g, '')
  const binary = atob(b64)
  const bytes = new Uint8Array(binary.length)
  for (let i = 0; i < binary.length; i++) {
    bytes[i] = binary.charCodeAt(i)
  }
  return bytes.buffer
}
