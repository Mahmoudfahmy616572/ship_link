-- إضافة الأعمدة الناقصة في جدول products عشان تطابق موديل AdminProduct
-- (الأعمدة status, qty, is_offer, new_price, popular مش موجودة حالياً فبتسبب 400)
-- نفذ هذا الملف في Supabase SQL Editor.

ALTER TABLE public.products
  ADD COLUMN IF NOT EXISTS status integer NOT NULL DEFAULT 1,
  ADD COLUMN IF NOT EXISTS qty integer NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS is_offer boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS new_price numeric,
  ADD COLUMN IF NOT EXISTS popular integer NOT NULL DEFAULT 0;

-- نمنح صلاحية القراءة/الكتابة للأدمن (حسب سياسات RLS الموجودة)
-- ملاحظة: لو فيه RLS على products، تأكد إن الأدمن (auth.uid() في admins نشط) عنده صلاحية.
