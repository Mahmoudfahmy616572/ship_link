-- Phase 1: add delivery coordinates to the orders table.
-- These columns are already written by checkout (cart_repository_impl) and
-- read by order_detail / driver orders_map, but were missing from the schema.
-- Idempotent and non-destructive.
ALTER TABLE orders ADD COLUMN IF NOT EXISTS delivery_address TEXT;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS delivery_lat DOUBLE PRECISION;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS delivery_lng DOUBLE PRECISION;


