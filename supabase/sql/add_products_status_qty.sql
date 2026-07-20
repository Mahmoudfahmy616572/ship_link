-- نضيف أعمدة status و qty لجدول products عشان الـ admin يقدر يفعل/يعطل ويشوف الكمية
-- شغّل ده في Supabase SQL Editor

ALTER TABLE products ADD COLUMN IF NOT EXISTS status INTEGER NOT NULL DEFAULT 1;
ALTER TABLE products ADD COLUMN IF NOT EXISTS qty INTEGER NOT NULL DEFAULT 0;

-- نتأكد إن فيه قيم افتراضية للقديم
UPDATE products SET status = 1 WHERE status IS NULL;
UPDATE products SET qty = 0 WHERE qty IS NULL;
