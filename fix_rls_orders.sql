-- =============================================================
-- Fix RLS policies for orders table
-- Users need UPDATE permission for their own orders
-- (e.g., setting payment_method after checkout)
-- =============================================================

-- Drop the overly-restrictive driver-only update policy
DROP POLICY IF EXISTS "Drivers can update orders" ON orders;

-- Recreate: drivers can update orders assigned to them OR available orders
CREATE POLICY "Drivers can update orders" ON orders
  FOR UPDATE
  USING (auth.uid() = driver_id OR driver_id IS NULL)
  WITH CHECK (auth.uid() = driver_id);

-- NEW: users can update their own orders (payment_method, cancel, etc.)
DROP POLICY IF EXISTS "Users can update own orders" ON orders;
CREATE POLICY "Users can update own orders" ON orders
  FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Keep these as they are:
-- "Users can view own orders"  → SELECT: auth.uid() = user_id OR auth.uid() = driver_id
-- "Users can insert orders"    → INSERT: WITH CHECK (auth.uid() = user_id)

-- Drop the overly-permissive "allow_all_authenticated" if it exists
DROP POLICY IF EXISTS "allow_all_authenticated" ON orders;

-- =============================================================
-- Verify all policies on orders table
-- =============================================================
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
FROM pg_policies
WHERE tablename = 'orders'
ORDER BY policyname;
