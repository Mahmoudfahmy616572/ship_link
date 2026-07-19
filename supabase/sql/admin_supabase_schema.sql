-- =============================================================
-- SHIPLINK ADMIN DASHBOARD MIGRATION (FINAL / STABLE VERSION)
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

-- نسيب الـ RLS متفعّل على admins بس الـ policy بتاعته آمن (subquery مش recursive)
ALTER TABLE admins ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Admins can read admins" ON admins;
CREATE POLICY "Admins can read admins" ON admins
  FOR SELECT USING (auth.uid() IN (SELECT id FROM admins WHERE is_active = true));

DROP POLICY IF EXISTS "Super admins can manage admins" ON admins;
CREATE POLICY "Super admins can manage admins" ON admins
  FOR ALL USING (
    auth.uid() IN (SELECT id FROM admins WHERE is_active = true AND role = 'super_admin')
  );

-- 2. نمنح صلاحيات للـ authenticated على الجدول
GRANT SELECT, INSERT, UPDATE, DELETE ON admins TO authenticated;

-- 3. ملاحظة: متستخدمش trigger يعدّل auth.users أو raw_app_meta_data.
--    الـ RLS على الجداول التانية بيتأكد من عضوية الـ user في جدول admins
--    عن طريق subquery (auth.uid() IN (SELECT id FROM admins WHERE is_active = true))
--    ده أضمن من الـ JWT role اللي كان بيعمل 500.

-- 4. Admin RLS policies on core tables (read/update access for admins).
--    بنستخدم subquery على admins بدل auth.jwt()->>'role' = 'admin'

-- profiles
DROP POLICY IF EXISTS "Admins can view all profiles" ON profiles;
CREATE POLICY "Admins can view all profiles" ON profiles
  FOR SELECT USING (auth.uid() IN (SELECT id FROM admins WHERE is_active = true));

DROP POLICY IF EXISTS "Users can view own profile" ON profiles;
CREATE POLICY "Users can view own profile" ON profiles
  FOR SELECT USING (auth.uid() = id OR auth.uid() IN (SELECT id FROM admins WHERE is_active = true));

-- drivers: admins can read all + update (approve/suspend)
DROP POLICY IF EXISTS "Admins can view all drivers" ON drivers;
CREATE POLICY "Admins can view all drivers" ON drivers
  FOR SELECT USING (auth.uid() IN (SELECT id FROM admins WHERE is_active = true));

DROP POLICY IF EXISTS "Admins can update drivers" ON drivers;
CREATE POLICY "Admins can update drivers" ON drivers
  FOR UPDATE USING (auth.uid() IN (SELECT id FROM admins WHERE is_active = true))
  WITH CHECK (auth.uid() IN (SELECT id FROM admins WHERE is_active = true));

-- orders: admins can read all + update (status management)
DROP POLICY IF EXISTS "Admins can view all orders" ON orders;
CREATE POLICY "Admins can view all orders" ON orders
  FOR SELECT USING (auth.uid() IN (SELECT id FROM admins WHERE is_active = true));

DROP POLICY IF EXISTS "Admins can update orders" ON orders;
CREATE POLICY "Admins can update orders" ON orders
  FOR UPDATE USING (auth.uid() IN (SELECT id FROM admins WHERE is_active = true))
  WITH CHECK (auth.uid() IN (SELECT id FROM admins WHERE is_active = true));

-- products: admins can manage
DROP POLICY IF EXISTS "Admins can manage products" ON products;
CREATE POLICY "Admins can manage products" ON products
  FOR ALL USING (auth.uid() IN (SELECT id FROM admins WHERE is_active = true))
  WITH CHECK (auth.uid() IN (SELECT id FROM admins WHERE is_active = true));

-- support_messages: admins can read + reply
DROP POLICY IF EXISTS "Admins can view all support messages" ON support_messages;
CREATE POLICY "Admins can view all support messages" ON support_messages
  FOR SELECT USING (auth.uid() IN (SELECT id FROM admins WHERE is_active = true));

DROP POLICY IF EXISTS "Admins can insert support replies" ON support_messages;
CREATE POLICY "Admins can insert support replies" ON support_messages
  FOR INSERT WITH CHECK (auth.uid() IN (SELECT id FROM admins WHERE is_active = true));

-- promo_codes: admins can manage
DROP POLICY IF EXISTS "Admins can manage promo_codes" ON promo_codes;
CREATE POLICY "Admins can manage promo_codes" ON promo_codes
  FOR ALL USING (auth.uid() IN (SELECT id FROM admins WHERE is_active = true))
  WITH CHECK (auth.uid() IN (SELECT id FROM admins WHERE is_active = true));

-- reviews: admins can read + delete
DROP POLICY IF EXISTS "Admins can manage reviews" ON reviews;
CREATE POLICY "Admins can manage reviews" ON reviews
  FOR ALL USING (auth.uid() IN (SELECT id FROM admins WHERE is_active = true))
  WITH CHECK (auth.uid() IN (SELECT id FROM admins WHERE is_active = true));

-- =============================================================
-- ADMIN SEED HELPER (run manually with your admin email):
--   1) Create the user via Supabase Auth (email + password).
--   2) Then run:
--      INSERT INTO admins (id, email, full_name, role, is_active)
--      VALUES ('<USER_UUID>', 'admin@shiplink.app', 'Site Admin', 'super_admin', true)
--      ON CONFLICT (id) DO UPDATE SET is_active = true, role = 'super_admin';
-- =============================================================

-- =============================================================
-- STORAGE BUCKET FOR PRODUCT IMAGES
-- Create the bucket (run once in SQL Editor or via Dashboard):
--   insert into storage.buckets (id, name, public) values ('product-images', 'product-images', true);
-- Then allow authenticated admins to upload (RLS on storage.objects):
--   create policy "Admins can upload product images"
--     on storage.objects for insert to authenticated
--     with check (bucket_id = 'product-images' and auth.uid() in (select id from admins where is_active = true));
--   create policy "Public can read product images"
--     on storage.objects for select using (bucket_id = 'product-images');
-- =============================================================
