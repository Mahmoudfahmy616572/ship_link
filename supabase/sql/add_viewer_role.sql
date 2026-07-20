-- نتأكد إن الـ viewer موجود في admins بـ role صح (ده بيصلح لو row موجود بس role غلط)
INSERT INTO public.admins (id, email, full_name, role, is_active)
SELECT
  id,
  email,
  COALESCE((SELECT full_name FROM public.admins WHERE email = 'viewer@unipath.com' LIMIT 1), 'Viewer'),
  'viewer',
  true
FROM auth.users
WHERE email = 'viewer@unipath.com'
ON CONFLICT (id) DO UPDATE
  SET role = 'viewer', is_active = true, full_name = COALESCE(EXCLUDED.full_name, 'Viewer');

-- نطبع النتيجة عشان نتأكد
SELECT id, email, role, is_active FROM public.admins WHERE email = 'viewer@unipath.com';
