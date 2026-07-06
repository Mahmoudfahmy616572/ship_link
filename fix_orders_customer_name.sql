ALTER TABLE orders ADD COLUMN IF NOT EXISTS customer_name TEXT;

UPDATE orders o
SET customer_name = p.name
FROM profiles p
WHERE o.user_id = p.id
  AND (o.customer_name IS NULL OR o.customer_name = '');
