-- 1. user_addresses table
CREATE TABLE IF NOT EXISTS user_addresses (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  label TEXT DEFAULT 'Home',
  city TEXT DEFAULT '',
  street TEXT DEFAULT '',
  building TEXT DEFAULT '',
  apartment TEXT DEFAULT '',
  full_address TEXT DEFAULT '',
  latitude DOUBLE PRECISION,
  longitude DOUBLE PRECISION,
  is_default BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE user_addresses ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "users_crud_own_addresses" ON user_addresses;
CREATE POLICY "users_crud_own_addresses"
  ON user_addresses
  FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- 2. RLS for orders table (if not already enabled)
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;

-- Scoped policies only. NEVER use a blanket "allow_all_authenticated" policy:
-- permissive RLS policies combine with OR, so a blanket authenticated policy
-- would grant every signed-in user full CRUD on ALL orders.
DROP POLICY IF EXISTS "allow_all_authenticated" ON orders;
DROP POLICY IF EXISTS "users_view_own_orders" ON orders;
CREATE POLICY "users_view_own_orders"
  ON orders FOR SELECT
  USING (auth.uid() = user_id OR auth.uid() = driver_id);
DROP POLICY IF EXISTS "users_insert_own_orders" ON orders;
CREATE POLICY "users_insert_own_orders"
  ON orders FOR INSERT
  WITH CHECK (auth.uid() = user_id);
DROP POLICY IF EXISTS "users_update_own_orders" ON orders;
CREATE POLICY "users_update_own_orders"
  ON orders FOR UPDATE
  USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
DROP POLICY IF EXISTS "drivers_update_assigned_orders" ON orders;
CREATE POLICY "drivers_update_assigned_orders"
  ON orders FOR UPDATE
  USING (auth.uid() = driver_id OR driver_id IS NULL)
  WITH CHECK (auth.uid() = driver_id);

-- 3. notifications table (for push & in-app)
CREATE TABLE IF NOT EXISTS notifications (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  type TEXT DEFAULT 'general',
  read BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now(),
  data JSONB
);

ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "users_read_own_notifications" ON notifications;
CREATE POLICY "users_read_own_notifications"
  ON notifications
  FOR SELECT
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "service_insert_notifications" ON notifications;
CREATE POLICY "service_insert_notifications"
  ON notifications
  FOR INSERT
  WITH CHECK (
    auth.uid() = user_id
    OR EXISTS (SELECT 1 FROM drivers WHERE drivers.id = auth.uid())
  );

-- Add data column for existing installations
ALTER TABLE notifications ADD COLUMN IF NOT EXISTS data JSONB;

-- 4. add fcm_token column to profiles if not exists
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS fcm_token TEXT;


