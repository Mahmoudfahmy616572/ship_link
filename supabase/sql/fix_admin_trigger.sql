-- =============================================================
-- إصلاح جدول admins + الـ trigger (النسخة الآمنة)
-- =============================================================

-- نتأكد إن الجدول موجود
CREATE TABLE IF NOT EXISTS admins (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT,
  full_name TEXT,
  role TEXT DEFAULT 'admin',
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE admins ENABLE ROW LEVEL SECURITY;

-- نمسح الـ trigger والـ function القديمين (عشان نعيدهم صح)
DROP TRIGGER IF EXISTS trg_set_admin_jwt_claim ON admins;
DROP FUNCTION IF EXISTS public.set_admin_jwt_claim();

-- نعمل function أبسط وأمتن (بنستخدم auth.admin بدل تعديل auth.users مباشرة)
CREATE OR REPLACE FUNCTION public.set_admin_jwt_claim()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  -- نحدث الـ role في app_metadata عن طريق دالة النظام الآمنة
  IF NEW.is_active THEN
    PERFORM auth.admin_update_user_by_id(
      NEW.id,
      NULL,  -- لا نغير الإيميل
      NULL,  -- ولا الباسورد
      (jsonb_build_object('role', NEW.role))::jsonb
    );
  ELSE
    PERFORM auth.admin_update_user_by_id(
      NEW.id,
      NULL,
      NULL,
      (jsonb_build_object('role', NULL))::jsonb
    );
  END IF;
  RETURN NEW;
EXCEPTION WHEN OTHERS THEN
  -- لو فيه أي خطأ، نرجع NEW من غير ما نكسر الـ insert
  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_set_admin_jwt_claim
  AFTER INSERT OR UPDATE OF is_active, role ON admins
  FOR EACH ROW
  EXECUTE FUNCTION public.set_admin_jwt_claim();

-- نتأكد إن الإيميل بتاعك موجود في الجدول (استبدل الـ UUID والإيميل لو محتاج)
-- ملاحظة: لازم تكون عامل المستخدم من Authentication وأخدت الـ UUID بتاعه
INSERT INTO admins (id, email, full_name, role, is_active)
VALUES (
  '614c3b66-d33f-40d9-8c13-8968b902c13a',
  'mahmoudadmin@gmail.com',
  'Mahmoud Admin',
  'super_admin',
  true
)
ON CONFLICT (id) DO UPDATE SET is_active = true, role = 'super_admin', updated_at = now();

-- نمنح صلاحيات للـ function
GRANT EXECUTE ON FUNCTION public.set_admin_jwt_claim() TO authenticated;
GRANT EXECUTE ON FUNCTION public.set_admin_jwt_claim() TO service_role;
