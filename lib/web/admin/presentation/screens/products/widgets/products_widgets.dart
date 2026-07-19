import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/widgets/app_style.dart';
import 'package:ship_link/web/admin/domain/models/admin_models.dart';
import 'package:ship_link/web/admin/presentation/cubits/products/admin_products_cubit.dart';
import 'package:ship_link/web/admin/presentation/screens/shared/admin_theme_mode.dart';
import 'package:ship_link/web/admin/presentation/utils/admin_date_formatter.dart';

String _priceText(AdminProduct p) {
  if (p.isOffer && p.newPrice != null) {
    return '${p.newPrice!.toStringAsFixed(0)} EGP';
  }
  return '${(p.price ?? 0).toStringAsFixed(0)} EGP';
}

// جدول المنتجات (موبايل بيكارت)
class ProductsTable extends StatelessWidget {
  final List<AdminProduct> products;
  final void Function(AdminProduct product) onEdit;
  final void Function(AdminProduct product) onDelete;
  final void Function(AdminProduct product)? onOpen;
  final void Function(AdminProduct product)? onToggleStatus;
  final Set<int> selectedIds;
  final void Function(int id) onToggleSelect;
  final bool isSelectionMode;
  final bool isCompact;
  final bool canManage;
  const ProductsTable(
    this.products, {
    super.key,
    required this.onEdit,
    required this.onDelete,
    this.onOpen,
    this.onToggleStatus,
    this.selectedIds = const {},
    this.onToggleSelect = _noop,
    this.isSelectionMode = false,
    this.isCompact = false,
    this.canManage = true,
  });

  static void _noop(int _) {}

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    if (isCompact) {
      return Column(
        children: products.map((p) {
          final img = p.image;
          final statusText = p.status == 1 ? t.tr('active') : t.tr('inactive');
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AdminThemeMode.surface(AdminThemeMode.isDark.value),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AdminThemeMode.border(AdminThemeMode.isDark.value)),
            ),
            child: InkWell(
              onTap: isSelectionMode
                  ? () => onToggleSelect(p.id ?? -1)
                  : () => onOpen?.call(p),
              child: Row(
                children: [
                if (isSelectionMode)
                  Checkbox(value: selectedIds.contains(p.id), onChanged: (_) => onToggleSelect(p.id ?? -1))
                else
                  const SizedBox.shrink(),
                if (img != null && img.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(img, width: 56, height: 56, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(width: 56, height: 56, color: AdminThemeMode.bg(AdminThemeMode.isDark.value))),
                  )
                else
                  Container(width: 56, height: 56, decoration: BoxDecoration(color: AdminThemeMode.bg(AdminThemeMode.isDark.value), borderRadius: BorderRadius.circular(8))),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.name?.isNotEmpty == true ? p.name! : '—', style: appStyle(15, FontWeight.w700, AdminThemeMode.textPrimary(AdminThemeMode.isDark.value))),
                      const SizedBox(height: 4),
                      Text(_priceText(p), style: appStyle(13, FontWeight.w600, AppColors.primary)),
                      const SizedBox(height: 2),
                      Text('${t.tr('category')}: ${p.category ?? '—'} • ${t.tr('qty')}: ${p.qty}',
                          style: appStyle(12, FontWeight.w400, AdminThemeMode.textSecondary(AdminThemeMode.isDark.value))),
                      const SizedBox(height: 2),
                      Text(AdminDateFormatter.formatDate(p.createdAt, locale: Localizations.localeOf(context).languageCode),
                          style: appStyle(11, FontWeight.w400, AdminThemeMode.textSecondary(AdminThemeMode.isDark.value))),
                    ],
                  ),
                ),
                if (canManage)
                  Column(
                    children: [
                      if (onToggleStatus != null)
                        InkWell(
                          onTap: () => onToggleStatus!(p),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: p.status == 1 ? AppColors.success.withValues(alpha: 0.12) : AdminThemeMode.textSecondary(AdminThemeMode.isDark.value).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(statusText, style: appStyle(11, FontWeight.w600, p.status == 1 ? AppColors.success : AdminThemeMode.textSecondary(AdminThemeMode.isDark.value))),
                                const SizedBox(width: 3),
                                Icon(p.status == 1 ? Icons.toggle_on : Icons.toggle_off, size: 14, color: p.status == 1 ? AppColors.success : AdminThemeMode.textSecondary(AdminThemeMode.isDark.value)),
                              ],
                            ),
                          ),
                        ),
                      IconButton(onPressed: () => onEdit(p), icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary)),
                      IconButton(onPressed: () => onDelete(p), icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error)),
                    ],
                  ),
              ],
              ),
            ),
          );
        }).toList(),
      );
    }
    final columns = [if (isSelectionMode) '', t.tr('image'), t.tr('name'), t.tr('category'), t.tr('price'), t.tr('qty'), t.tr('status'), t.tr('actions')];
    return Container(
      decoration: BoxDecoration(
        color: AdminThemeMode.surface(AdminThemeMode.isDark.value),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminThemeMode.border(AdminThemeMode.isDark.value)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: columns.map((c) => DataColumn(label: Text(c, style: appStyle(13, FontWeight.w600, AdminThemeMode.textSecondary(AdminThemeMode.isDark.value))))).toList(),
          rows: products.map((p) {
            final img = p.image;
            final statusText = p.status == 1 ? t.tr('active') : t.tr('inactive');
            return DataRow(
              onSelectChanged: isSelectionMode ? (_) => onToggleSelect(p.id ?? -1) : (_) => onOpen?.call(p),
              cells: [
              if (isSelectionMode)
                DataCell(Checkbox(value: selectedIds.contains(p.id), onChanged: (_) => onToggleSelect(p.id ?? -1))),
              DataCell(img != null && img.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(img, width: 40, height: 40, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(width: 40, height: 40, color: AdminThemeMode.bg(AdminThemeMode.isDark.value))),
                    )
                  : Container(width: 40, height: 40, decoration: BoxDecoration(color: AdminThemeMode.bg(AdminThemeMode.isDark.value), borderRadius: BorderRadius.circular(6)))),
              DataCell(Text(p.name?.isNotEmpty == true ? p.name! : '—', style: appStyle(14, FontWeight.w500, AdminThemeMode.textPrimary(AdminThemeMode.isDark.value)))),
              DataCell(Text(p.category ?? '—', style: appStyle(14, FontWeight.w400, AdminThemeMode.textSecondary(AdminThemeMode.isDark.value)))),
              DataCell(Text(_priceText(p), style: appStyle(14, FontWeight.w600, AppColors.primary))),
              DataCell(Text('${p.qty}', style: appStyle(14, FontWeight.w400, AdminThemeMode.textSecondary(AdminThemeMode.isDark.value)))),
              DataCell(canManage && onToggleStatus != null
                  ? InkWell(
                      onTap: () => onToggleStatus!(p),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: p.status == 1 ? AppColors.success.withValues(alpha: 0.12) : AdminThemeMode.textSecondary(AdminThemeMode.isDark.value).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(statusText, style: appStyle(12, FontWeight.w600, p.status == 1 ? AppColors.success : AdminThemeMode.textSecondary(AdminThemeMode.isDark.value))),
                            const SizedBox(width: 4),
                            Icon(p.status == 1 ? Icons.toggle_on : Icons.toggle_off, size: 16, color: p.status == 1 ? AppColors.success : AdminThemeMode.textSecondary(AdminThemeMode.isDark.value)),
                          ],
                        ),
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: p.status == 1 ? AppColors.success.withValues(alpha: 0.12) : AdminThemeMode.textSecondary(AdminThemeMode.isDark.value).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(statusText, style: appStyle(12, FontWeight.w600, p.status == 1 ? AppColors.success : AdminThemeMode.textSecondary(AdminThemeMode.isDark.value))),
                    )),
              DataCell(canManage
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(onPressed: () => onEdit(p), icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary), tooltip: t.tr('edit')),
                        IconButton(onPressed: () => onDelete(p), icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error), tooltip: t.tr('delete')),
                      ],
                    )
                  : const SizedBox.shrink()),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}

class ProductsTableShimmer extends StatelessWidget {
  const ProductsTableShimmer({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320,
      decoration: BoxDecoration(
        color: AdminThemeMode.surface(AdminThemeMode.isDark.value),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminThemeMode.border(AdminThemeMode.isDark.value)),
      ),
    );
  }
}

class ProductsErrorView extends StatelessWidget {
  final String message;
  const ProductsErrorView(this.message, {super.key});
  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: 12),
          Text(message, style: appStyle(14, FontWeight.w500, AdminThemeMode.textSecondary(AdminThemeMode.isDark.value))),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: () => context.read<AdminProductsCubit>().loadProducts(), child: Text(t.tr('retry'))),
        ],
      ),
    );
  }
}
