DROP POLICY IF EXISTS "Users can delete own notifications" ON notifications;
CREATE POLICY "Users can delete own notifications"
  ON notifications FOR DELETE
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete own support messages" ON support_messages;
CREATE POLICY "Users can delete own support messages"
  ON support_messages FOR DELETE
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Participants can delete own messages" ON order_chat_messages;
CREATE POLICY "Participants can delete own messages"
  ON order_chat_messages FOR DELETE
  USING (sender_id = auth.uid());
