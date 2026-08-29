-- Phase 8: add push_sent flag to notifications so send_push can record delivery status.
-- Non-destructive / idempotent.

ALTER TABLE notifications
  ADD COLUMN IF NOT EXISTS push_sent BOOLEAN NOT NULL DEFAULT false;


