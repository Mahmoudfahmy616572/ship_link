-- نضيف حساب الـ viewer في جدول admins (نربطه بالـ auth user عن طريق id)
INSERT INTO public.admins (id, email, full_name, role, is_active)
SELECT
  id,
  email,
  'Viewer',
  'viewer',
  true
FROM auth.users
WHERE email = 'viewer@unipath.com'
ON CONFLICT (id) DO UPDATE
  SET role = 'viewer', is_active = true;
