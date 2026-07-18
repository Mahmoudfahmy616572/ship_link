-- =============================================================
-- SHIPLINK ADMIN DASHBOARD MIGRATION
-- Run this in Supabase SQL Editor (after complete_supabase_schema.sql)
-- =============================================================

-- 1. ADMINS table (uses auth.users for login)
CREATE TABLE IF NOT EXISTS admins (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT,
  full_name TEXT,
  role TEXT DEFAULT 'admin',          -- 'admin' | 'super_admin'
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE admins ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Admins can read admins" ON admins;
CREATE POLICY "Admins can read admins" ON admins
  FOR SELECT USING (auth.uid() IN (SELECT id FROM admins WHERE is_active = true));

DROP POLICY IF EXISTS "Super admins can manage admins" ON admins;
CREATE POLICY "Super admins can manage admins" ON admins
  FOR ALL USING (
    auth.uid() IN (SELECT id FROM admins WHERE is_active = true AND role = 'super_admin')
  );

-- 2. Mirror admin flag into profiles so existing policies (auth.jwt()->>'role' = 'admin') work
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS is_admin BOOLEAN DEFAULT false;

-- 3. Set the JWT `role` claim to 'admin' for admin users.
--    This makes auth.jwt()->>'role' = 'admin' TRUE and unlocks the admin
--    policies already present in complete_supabase_schema.sql.
CREATE OR REPLACE FUNCTION public.set_admin_jwt_claim()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF NEW.is_active THEN
    UPDATE auth.users
      SET raw_app_meta_data =
        COALESCE(raw_app_meta_data, '{}'::jsonb) || jsonb_build_object('role', NEW.role)
      WHERE id = NEW.id;
  ELSE
    UPDATE auth.users
      SET raw_app_meta_data =
        COALESCE(raw_app_meta_data, '{}'::jsonb) - 'role'
      WHERE id = NEW.id;
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_set_admin_jwt_claim ON admins;
CREATE TRIGGER trg_set_admin_jwt_claim
  AFTER INSERT OR UPDATE OF is_active, role ON admins
  FOR EACH ROW
  EXECUTE FUNCTION public.set_admin_jwt_claim();

-- Backfill any pre-existing admins into auth.users app_metadata
UPDATE auth.users u
  SET raw_app_meta_data = COALESCE(raw_app_meta_data, '{}'::jsonb) || jsonb_build_object('role', a.role)
  FROM admins a
  WHERE a.id = u.id AND a.is_active;

-- 4. Admin RLS policies on core tables (read access for admins).
--    profiles (extend existing): admins can read all
DROP POLICY IF EXISTS "Admins can view all profiles" ON profiles;
CREATE POLICY "Admins can view all profiles" ON profiles
  FOR SELECT USING (auth.jwt()->>'role' = 'admin');

-- drivers: admins can read all + update (approve/suspend)
DROP POLICY IF EXISTS "Admins can view all drivers" ON drivers;
CREATE POLICY "Admins can view all drivers" ON drivers
  FOR SELECT USING (auth.jwt()->>'role' = 'admin');
DROP POLICY IF EXISTS "Admins can update drivers" ON drivers;
CREATE POLICY "Admins can update drivers" ON drivers
  FOR UPDATE USING (auth.jwt()->>'role' = 'admin') WITH CHECK (auth.jwt()->>'role' = 'admin');

-- orders: admins can read all + update (status management)
DROP POLICY IF EXISTS "Admins can view all orders" ON orders;
CREATE POLICY "Admins can view all orders" ON orders
  FOR SELECT USING (auth.jwt()->>'role' = 'admin');
DROP POLICY IF EXISTS "Admins can update orders" ON orders;
CREATE POLICY "Admins can update orders" ON orders
  FOR UPDATE USING (auth.jwt()->>'role' = 'admin') WITH CHECK (auth.jwt()->>'role' = 'admin');

-- products: admins can manage
DROP POLICY IF EXISTS "Admins can manage products" ON products;
CREATE POLICY "Admins can manage products" ON products
  FOR ALL USING (auth.jwt()->>'role' = 'admin') WITH CHECK (auth.jwt()->>'role' = 'admin');

-- support_messages: admins can read + reply
DROP POLICY IF EXISTS "Admins can view all support messages" ON support_messages;
CREATE POLICY "Admins can view all support messages" ON support_messages
  FOR SELECT USING (auth.jwt()->>'role' = 'admin');
DROP POLICY IF EXISTS "Admins can insert support replies" ON support_messages;
CREATE POLICY "Admins can insert support replies" ON support_messages
  FOR INSERT WITH CHECK (auth.jwt()->>'role' = 'admin');

-- promo_codes: admins can manage
DROP POLICY IF EXISTS "Admins can manage promo_codes" ON promo_codes;
CREATE POLICY "Admins can manage promo_codes" ON promo_codes
  FOR ALL USING (auth.jwt()->>'role' = 'admin') WITH CHECK (auth.jwt()->>'role' = 'admin');

-- reviews: admins can read + delete
DROP POLICY IF EXISTS "Admins can manage reviews" ON reviews;
CREATE POLICY "Admins can manage reviews" ON reviews
  FOR ALL USING (auth.jwt()->>'role' = 'admin') WITH CHECK (auth.jwt()->>'role' = 'admin');

-- =============================================================
-- ADMIN SEED HELPER (run manually with your admin email):
--   1) Create the user via Supabase Auth (email + password).
--   2) Then run:
--      INSERT INTO admins (id, email, full_name, role, is_active)
--      VALUES ('<USER_UUID>', 'admin@shiplink.app', 'Site Admin', 'super_admin', true)
--      ON CONFLICT (id) DO UPDATE SET is_active = true, role = 'super_admin';
-- =============================================================
