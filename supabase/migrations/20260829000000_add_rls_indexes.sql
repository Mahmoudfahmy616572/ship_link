-- Phase 7: performance indexes for RLS evaluation and notification polling.
-- Safe / idempotent; non-destructive.

CREATE INDEX IF NOT EXISTS idx_orders_user_id ON orders (user_id);
CREATE INDEX IF NOT EXISTS idx_orders_driver_id ON orders (driver_id);
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications (user_id);


