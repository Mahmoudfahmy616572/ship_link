-- QA BUG-002: tighten notifications INSERT RLS. The client inserts
-- notifications with user_id = recipient (e.g. driver -> customer), so a naive
-- "auth.uid() = user_id" check would break that flow. Instead allow the
-- recipient themselves, or any driver, to create notifications. This blocks a
-- customer from forging notifications for *another* customer while preserving
-- the legitimate driver -> customer path. Server/edge inserts use service_role
-- and bypass RLS entirely.

DROP POLICY IF EXISTS "Users can insert notifications" ON notifications;
DROP POLICY IF EXISTS "service_insert_notifications" ON notifications;

DROP POLICY IF EXISTS "Users can insert notifications" ON notifications;
CREATE POLICY "Users can insert notifications" ON notifications
  FOR INSERT WITH CHECK (
    auth.uid() = user_id
    OR EXISTS (SELECT 1 FROM drivers WHERE drivers.id = auth.uid())
  );


