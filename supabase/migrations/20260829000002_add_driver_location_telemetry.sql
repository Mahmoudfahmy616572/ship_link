-- QA BUG-001: promote driver_locations telemetry columns into a versioned
-- migration so Supabase auto-applies it. Previously only in the ad-hoc
-- supabase/sql/phase5_driver_locations.sql, which Supabase does NOT run
-- automatically. driver_tracking_session.dart upserts heading/speed/accuracy/
-- last_seen/is_online, so these columns must exist on the live DB or live
-- tracking writes fail.

ALTER TABLE driver_locations
  ADD COLUMN IF NOT EXISTS heading DOUBLE PRECISION,
  ADD COLUMN IF NOT EXISTS speed DOUBLE PRECISION,
  ADD COLUMN IF NOT EXISTS accuracy DOUBLE PRECISION,
  ADD COLUMN IF NOT EXISTS last_seen TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS is_online BOOLEAN DEFAULT FALSE;

CREATE INDEX IF NOT EXISTS driver_locations_last_seen_idx
  ON driver_locations (last_seen);

CREATE INDEX IF NOT EXISTS driver_locations_updated_at_idx
  ON driver_locations (updated_at);


