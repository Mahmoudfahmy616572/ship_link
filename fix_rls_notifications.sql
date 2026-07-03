-- Allow users to delete their own notifications
CREATE POLICY "Users can delete own notifications"
  ON notifications FOR DELETE
  USING (auth.uid() = user_id);

-- Allow users to delete their own support messages
CREATE POLICY "Users can delete own support messages"
  ON support_messages FOR DELETE
  USING (auth.uid() = user_id);

-- Allow participants to delete their own order chat messages
CREATE POLICY "Participants can delete own messages"
  ON order_chat_messages FOR DELETE
  USING (sender_id = auth.uid());
