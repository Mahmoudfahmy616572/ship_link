-- Phase 5: extend driver_locations for production-grade live tracking.
-- Adds movement/quality metadata consumed by the user app. No business logic
-- change; the existing RLS "Drivers can update own location" (FOR ALL,
-- auth.uid() = driver_id) already covers every column.

ALTER TABLE driver_locations
  ADD COLUMN IF NOT EXISTS heading DOUBLE PRECISION,
  ADD COLUMN IF NOT EXISTS speed DOUBLE PRECISION,
  ADD COLUMN IF NOT EXISTS accuracy DOUBLE PRECISION,
  ADD COLUMN IF NOT EXISTS last_seen TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS is_online BOOLEAN DEFAULT FALSE;

-- Support freshness / last-seen queries from realtime consumers.
CREATE INDEX IF NOT EXISTS driver_locations_last_seen_idx
  ON driver_locations (last_seen);

CREATE INDEX IF NOT EXISTS driver_locations_updated_at_idx
  ON driver_locations (updated_at);

-- Realtime publication: driver_locations is already tracked via Postgres
-- changes (user app subscribes with primaryKey ['driver_id']), so no
-- publication DDL change is required.
