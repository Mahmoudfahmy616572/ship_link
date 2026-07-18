-- =============================================================
-- SHIPLINK DRIVERS TABLE MIGRATION
-- Creates a separate drivers table independent from profiles
-- Run this AFTER complete_supabase_schema.sql
-- =============================================================

-- 1. Create drivers table (completely separate from profiles)
CREATE TABLE IF NOT EXISTS drivers (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT,
  email TEXT UNIQUE,
  phone_number TEXT UNIQUE,
  vehicle_type TEXT,
  vehicle_number TEXT,
  state TEXT,
  fcm_token TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE drivers ENABLE ROW LEVEL SECURITY;

-- RLS policies for drivers
DROP POLICY IF EXISTS "Drivers can insert own data" ON drivers;
CREATE POLICY "Drivers can insert own data"
  ON drivers FOR INSERT
  WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "Drivers can view own data" ON drivers;
CREATE POLICY "Drivers can view own data"
  ON drivers FOR SELECT
  USING (auth.uid() = id);

DROP POLICY IF EXISTS "Drivers can update own data" ON drivers;
CREATE POLICY "Drivers can update own data"
  ON drivers FOR UPDATE
  USING (auth.uid() = id);

-- 2. Ensure orders.user_id -> profiles FK exists (needed by PostgREST joins)
ALTER TABLE orders DROP CONSTRAINT IF EXISTS orders_user_id_fkey;
ALTER TABLE orders ADD CONSTRAINT orders_user_id_fkey
  FOREIGN KEY (user_id) REFERENCES profiles(id) ON DELETE CASCADE;

-- 3. Migrate existing driver data from profiles to drivers
-- (only safe known columns; extras like vehicle_number/state added by app later)
INSERT INTO drivers (id, name, email, phone_number)
SELECT p.id, p.name, p.email, p.phone_number
FROM profiles p
WHERE p.role = 'driver'
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  email = EXCLUDED.email,
  phone_number = EXCLUDED.phone_number;

-- 4. Update existing FK references to point to drivers instead of profiles
-- (only runs if the column exists in the table)
DO $$
BEGIN
  IF EXISTS (SELECT FROM information_schema.columns WHERE table_name = 'orders' AND column_name = 'driver_id') THEN
    ALTER TABLE orders DROP CONSTRAINT IF EXISTS orders_driver_id_fkey;
    ALTER TABLE orders ADD CONSTRAINT orders_driver_id_fkey
      FOREIGN KEY (driver_id) REFERENCES drivers(id) ON DELETE SET NULL;
  END IF;

  IF EXISTS (SELECT FROM information_schema.columns WHERE table_name = 'driver_locations' AND column_name = 'driver_id') THEN
    ALTER TABLE driver_locations DROP CONSTRAINT IF EXISTS driver_locations_driver_id_fkey;
    ALTER TABLE driver_locations ADD CONSTRAINT driver_locations_driver_id_fkey
      FOREIGN KEY (driver_id) REFERENCES drivers(id) ON DELETE CASCADE;
  END IF;
END $$;

