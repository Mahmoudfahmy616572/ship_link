import 'package:flutter/material.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/widgets/app_style.dart';
import 'package:ship_link/core/utils/sizer.dart';
import 'package:ship_link/web/admin/domain/models/admin_models.dart';
import 'package:ship_link/web/admin/presentation/screens/shared/admin_theme_mode.dart';
import 'package:ship_link/web/admin/presentation/utils/admin_date_formatter.dart';
import 'package:ship_link/web/admin/presentation/screens/shared/admin_stat_card.dart';

// شاشة تفاصيل منتج واحد (تفتح جوه الـ scaffold من غير Navigator.push)
class AdminProductDetailWeb extends StatelessWidget {
  final AdminProduct product;
  final VoidCallback onBack;
  final void Function(AdminProduct product)? onEdit;
  const AdminProductDetailWeb({super.key, required this.product, required this.onBack, this.onEdit});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final isDark = AdminThemeMode.isDark.value;
    final p = product;
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back), tooltip: t.tr('back')),
              SizedBox(width: 8.w),
              Expanded(child: Text(p.name?.isNotEmpty == true ? p.name! : '—', style: appStyle(22, FontWeight.w700, AdminThemeMode.textPrimary(isDark)))),
              if (onEdit != null)
                ElevatedButton.icon(
                  onPressed: () => onEdit!(p),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: Text(t.tr('edit')),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                ),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // صورة المنتج
              Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  color: AdminThemeMode.bg(isDark),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AdminThemeMode.border(isDark)),
                ),
                child: p.image != null && p.image!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(p.image!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.image_not_supported, size: 48, color: Colors.grey)),
                    ))
                    : const Center(child: Icon(Icons.image_not_supported, size: 48, color: Colors.grey)),
              ),
              SizedBox(width: 24.w),
              // بيانات المنتج
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DetailRow(t.tr('category'), p.category ?? '—'),
                    _DetailRow(t.tr('price'), p.isOffer && p.newPrice != null ? '${p.newPrice!.toStringAsFixed(0)} EGP' : '${(p.price ?? 0).toStringAsFixed(0)} EGP'),
                    if (p.isOffer && p.newPrice != null) _DetailRow(t.tr('old_price'), '${(p.price ?? 0).toStringAsFixed(0)} EGP'),
                    _DetailRow(t.tr('qty'), '${p.qty}'),
                    _DetailRow(t.tr('status'), p.status == 1 ? t.tr('active') : t.tr('inactive')),
                    _DetailRow(t.tr('popular'), p.popular == 1 ? t.tr('yes') : t.tr('no')),
                    _DetailRow(t.tr('top_seller'), p.isTopSeller ? t.tr('yes') : t.tr('no')),
                    _DetailRow(t.tr('date'), AdminDateFormatter.formatDate(p.createdAt, locale: Localizations.localeOf(context).languageCode)),
                    if (p.description?.isNotEmpty == true) ...[
                      SizedBox(height: 12.h),
                      Text(t.tr('description'), style: appStyle(14, FontWeight.w600, AdminThemeMode.textPrimary(isDark))),
                      SizedBox(height: 4.h),
                      Text(p.description!, style: appStyle(14, FontWeight.w400, AdminThemeMode.textSecondary(isDark))),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final isDark = AdminThemeMode.isDark.value;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 130, child: Text(label, style: appStyle(14, FontWeight.w600, AdminThemeMode.textSecondary(isDark)))),
          Expanded(child: Text(value, style: appStyle(14, FontWeight.w500, AdminThemeMode.textPrimary(isDark)))),
        ],
      ),
    );
  }
}
