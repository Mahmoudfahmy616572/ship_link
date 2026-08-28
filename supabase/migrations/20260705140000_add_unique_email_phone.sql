-- Add UNIQUE constraints on profiles.email and profiles.phone_number
-- Nullify duplicates instead of deleting (avoids cascading data loss)
UPDATE profiles SET email = NULL WHERE id IN (
  SELECT id FROM (
    SELECT id, ROW_NUMBER() OVER (
      PARTITION BY email ORDER BY created_at DESC NULLS LAST
    ) AS rn
    FROM profiles WHERE email IS NOT NULL
  ) dup WHERE rn > 1
);
UPDATE profiles SET phone_number = NULL WHERE id IN (
  SELECT id FROM (
    SELECT id, ROW_NUMBER() OVER (
      PARTITION BY phone_number ORDER BY created_at DESC NULLS LAST
    ) AS rn
    FROM profiles WHERE phone_number IS NOT NULL AND phone_number != ''
  ) dup WHERE rn > 1
);
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'profiles_email_key') THEN
    ALTER TABLE profiles ADD CONSTRAINT profiles_email_key UNIQUE (email);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'profiles_phone_number_key') THEN
    ALTER TABLE profiles ADD CONSTRAINT profiles_phone_number_key UNIQUE (phone_number);
  END IF;
END $$;

