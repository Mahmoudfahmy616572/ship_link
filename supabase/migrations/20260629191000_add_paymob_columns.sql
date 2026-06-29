ALTER TABLE orders ADD COLUMN IF NOT EXISTS paymob_order_id BIGINT;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS paid_at TIMESTAMPTZ;
CREATE INDEX IF NOT EXISTS idx_orders_paymob_order_id ON orders(paymob_order_id);
