DROP POLICY IF EXISTS "Drivers can view available orders" ON orders;
CREATE POLICY "Drivers can view available orders" ON orders
  FOR SELECT USING (
    driver_id IS NULL
    AND EXISTS (SELECT 1 FROM drivers WHERE id = auth.uid())
  );
