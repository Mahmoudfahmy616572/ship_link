# ملفات قاعدة البيانات (Supabase)

كل ملفات الـ SQL الخاصة بالمشروع مجمعة تحت `supabase/` وبتتوزع على 3 مستويات:

| المستوى | المسار | الاستخدام |
|---|---|---|
| **الأساسي** | `supabase/apply_all.sql` | تشغّله في SQL Editor على قاعدة جديدة |
| **Supabase CLI** | `supabase/migrations/` | بيتطبّق تلقائيًا مع `supabase db push` — **متنقلش منه** |
| **تصحيحي/إضافي** | `supabase/sql/` + جذر `supabase/` | بس لو محتاجها على قاعدة قديمة أو فيه مشكلة محددة |

---

## 1. الترتيب في Supabase SQL Editor

### على قاعدة جديدة (نظيفة)

1. **`supabase/apply_all.sql`** — السكيما الكاملة كلها (817 سطر).
   ده الملف **المجمّع (superset)** وبيتضمّن فعليًا:
   * `supabase/sql/complete_supabase_schema.sql` (19 جدول + RLS + indexes)
   * كل الـ migrations الـ 11 (مدمجة جواه — كل واحد معلّق بـ `-- FILE: supabase/migrations/...`)
   * `supabase/migrations/payment_methods.sql`
   * سياسة `Drivers can view available orders` (إصلاح شراء الطلبات المتاحة للسائق)

   > أي تعليق `-- FILE:` داخل `apply_all.sql` بينقل للمصدر الأصلي. لو هتعدّل،
   > عدّل في الملف الأصلي وبعدين حدّث `apply_all.sql` (أو شغّل الملف الأصلي بعده).

2. **`supabase/sql/admin_supabase_schema.sql`** — جدول `admins` + السياسات + الـ trigger.
   ⚠️ **مش موجود في `apply_all.sql`**، فلازم تشغّله لوحده بعد الخطوة 1.
   لو الـ trigger بتاعه اتعطّل → شغّل `supabase/sql/fix_admin_trigger.sql`.

3. بقية ملفات `sql/` → بس لو محتاجها (ملفات إصلاح/إضافة على قاعدة شغّالة).

### على قاعدة شغّالة (لها بيانات)

1. `supabase/apply_all.sql` — كله `IF NOT EXISTS` / `DROP IF EXISTS` → آمن على الوجود.
2. `supabase/sql/admin_supabase_schema.sql`.
3. أي إصلاح محددة من القسم 3 تحت.

---

## 2. `supabase/migrations/` — نظام Supabase CLI

بيتُقرأ تلقائيًا لما تعمل `supabase db push` — **متنقلوش من هنا**:

- `20260629191000_add_paymob_columns.sql`
- `20260702121000_add_delete_rls_policies.sql`
- `20260705120000_add_delivery_instructions.sql`
- `20260705130000_create_stock_watch.sql`
- `20260705140000_add_unique_email_phone.sql`
- `20260825000000_add_order_delivery_coords.sql`
- `20260829000000_add_rls_indexes.sql`
- `20260829000001_add_push_sent.sql`
- `20260829000002_add_driver_location_telemetry.sql`
- `20260829000003_tighten_notifications_insert_rls.sql`
- `payment_methods.sql`

> كلهم (بما فيها `payment_methods.sql`) **مدمجين بالفعل داخل `apply_all.sql`**،
> فلو شغّلت `apply_all.sql` على قاعدة جديدة متحتاجش ترجع لهم.

---

## 3. ملفات `supabase/sql/` الإضافية/التصحيحية

| الملف | الغرض | محتاجه؟ |
|---|---|---|
| `complete_supabase_schema.sql` | النسخة القديمة (557 سطر، 17 جدول) — **متضمّنة في `apply_all.sql`** | لا (سجل تاريخي) |
| `admin_supabase_schema.sql` | جدول `admins` + trigger | ✅ نعم (مش في `apply_all.sql`) |
| `fix_admin_trigger.sql` | إعادة تفعيل trigger بتاع `admins` | عند الحاجة |
| `fix_rls_orders.sql` / `fix_rls_notifications.sql` / `fix_rls_profiles.sql` | إصلاحات RLS قديمة | عند وجود مشكلة RLS |
| `fix_orders_customer_name.sql` | تعبئة `customer_name` في الطلبات | عند الحاجة |
| `add_products_columns.sql` / `add_products_status_qty.sql` | إضافة `status`/`qty`/`is_offer`/`new_price`/`popular` لجدول `products` | موجودة أصلًا في `apply_all.sql` |
| `phase5_driver_locations.sql` | أعمدة `heading/speed/accuracy/last_seen/is_online` في `driver_locations` | **مجمّدة** — الـ migration `20260829000002` بيعمل نفس الحاجة |
| `supabase_setup.sql` / `supabase_schema_notifications.sql` / `supabase_drivers_migration.sql` | ملفات أقدم (يستخدمها المشروع الأقدم) | لا |
| `add_viewer_role.sql` | بيدوّر على `viewer@unipath.com` — **نسخة متبقية من مشروع UniPath** ⚠️ | لا، متشغّلوش |

---

## 4. ملفات جذر `supabase/`

| الملف | الحالة |
|---|---|
| **`apply_all.sql`** | ✅ الملف الأساسي (المرجع) |
| **`fix_orders_select_rls.sql`** | سياسة واحدة بس: `Drivers can view available orders` (السائق يشوف الطلبات المفتوحة `driver_id IS NULL`) → شغّله **على القاعدة الحية فقط** لو السائق مش شايف الطلبات المتاحة ومش عايز تعيد تشغيل `apply_all.sql` كامل (نفس السياسة موجودة في `apply_all.sql` سطر 172) |
| `migration_paymob.sql` | ⚠️ **نسخة مكررة** من `migrations/20260629191000_add_paymob_columns.sql` (نفس المحتوى بالظبط) → **لا تشغّله**، الـ migration كافي |

---

## 5. تهيئة المنتجات الأولية

`scripts/seed_products.sql` (اتعمل من DummyJSON API) — شغّله بعد السكيما لو عايز بيانات تجريبية.

---

## إنشاء أول أدمن (يدوي)

بعد ما تشغّل `apply_all.sql` + `admin_supabase_schema.sql`، أنشئ المستخدم من
Authentication → Users، وبعدين:

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

---

## ملاحظات مهمة

- **ملاحظة في التعليق:** ترويسة `admin_supabase_schema.sql` لسه بتقول
  «after `complete_supabase_schema.sql`» — العبارة الصحيحة دلوقتي «after **`apply_all.sql`**».
- **الـ migrations القديمة مكرّرة مع `apply_all.sql`** — شغّلهم على قاعدة شغّالة مش هيعملوا مشاكل
  (`IF NOT EXISTS`)، بس مش لازم.
- **بيانات الدخول:** راجع `.env` (و `.env.example`) — `.env` متجاهَل في `.gitignore` وممنوع يترفع.
