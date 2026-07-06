import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (_req) => {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
  )

  const { data: watches, error } = await supabase
    .from('stock_watch')
    .select('id, user_id, product_id, products!inner(qty, name)')
    .eq('notified', false)
    .gt('products.qty', 0)

  if (error) {
    console.error('Query error:', error)
    return new Response(JSON.stringify({ error }), { status: 500 })
  }

  if (!watches || watches.length === 0) {
    return new Response(JSON.stringify({ notified: 0 }), { status: 200 })
  }

  let notifiedCount = 0
  for (const watch of watches) {
    const product = watch.products as { qty: number; name: string }
    if (!product || product.qty <= 0) continue

    const { error: notifError } = await supabase.from('notifications').insert({
      user_id: watch.user_id,
      title: 'Back in Stock!',
      body: `${product.name} is now back in stock. Order now!`,
      type: JSON.stringify({ type: 'product_available', productId: watch.product_id }),
      read: false,
      created_at: new Date().toISOString(),
    })
    if (notifError) {
      console.error('Notification insert error:', notifError)
      continue
    }

    await supabase.from('stock_watch').update({ notified: true }).eq('id', watch.id)
    notifiedCount++
  }

  return new Response(JSON.stringify({ notified: notifiedCount }), { status: 200 })
})
