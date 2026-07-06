-- ================================================================
-- Fix: Drivers can't see customer name/phone on order cards
-- Root cause: profiles RLS only allows auth.uid() = id (own profile)
-- Effect: PostgREST silently nulls the profiles(*) join data
-- Fix: Add policy allowing drivers to read profiles of users
--       whose orders are assigned to them
-- ================================================================

DROP POLICY IF EXISTS "Drivers can view order customer profiles" ON profiles;
CREATE POLICY "Drivers can view order customer profiles" ON profiles
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM orders
      WHERE orders.user_id = profiles.id
      AND orders.driver_id = auth.uid()
    )
  );
