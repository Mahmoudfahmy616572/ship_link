# ملفات قاعدة البيانات (Supabase)

كل ملفات الـ SQL الخاصة بالمشروع مجمعة هنا تحت نظام Supabase.

## الترتيب في Supabase SQL Editor

1. **complete_supabase_schema.sql** — السكيما الأساسية كلها (الجداول + RLS). مرة واحدة الأول.
2. **admin_supabase_schema.sql** — جدول الأدمن + السياسات + الـ trigger. بعد الأول.
3. باقي الملفات إصلاحات/إضافات (لو محتاجها):
   - supabase_setup.sql
   - supabase_schema_notifications.sql
   - supabase_drivers_migration.sql
   - fix_rls_orders.sql
   - fix_rls_notifications.sql
   - fix_rls_profiles.sql
   - fix_orders_customer_name.sql

## ملاحظة مهمة

فيه فولدر `supabase/migrations/` (أخو فولدر `sql/` ده) بيتبع نظام **Supabase CLI**
وبيُقرأ تلقائياً لما تعمل `supabase db push` — متنقلوش من هناك:
- migration_paymob.sql
- migrations/payment_methods.sql
- migrations/20260705140000_add_unique_email_phone.sql
- migrations/20260705130000_create_stock_watch.sql
- migrations/20260705120000_add_delivery_instructions.sql
- migrations/20260702121000_add_delete_rls_policies.sql
- migrations/20260629191000_add_paymob_columns.sql

وكمان `scripts/seed_products.sql` لتهيئة المنتجات الأولية.

## إنشاء أول أدمن (يدوي)

بعد ما تشغّل الـ SQL، انشئ المستخدم من Authentication → Users، وبعدين:

```sql
INSERT INTO admins (id, email, full_name, role, is_active)
VALUES (
  'UUID_بتاع_المستخدم',
  'admin@shiplink.app',
  'Site Admin',
  'super_admin',
  true
)
ON CONFLICT (id) DO UPDATE SET is_active = true, role = 'super_admin';
```
