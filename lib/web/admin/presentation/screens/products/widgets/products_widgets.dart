import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/widgets/app_style.dart';
import 'package:ship_link/web/admin/presentation/cubits/products/admin_products_cubit.dart';

String _priceText(Map<String, dynamic> p) {
  final price = (p['price'] is num ? (p['price'] as num).toDouble() : 0.0);
  final isOffer = p['is_offer'] == true;
  final newPrice = (p['new_price'] is num ? (p['new_price'] as num).toDouble() : null);
  if (isOffer && newPrice != null) {
    return '${newPrice.toStringAsFixed(0)} EGP';
  }
  return '${price.toStringAsFixed(0)} EGP';
}

// جدول المنتجات (موبايل بيكارت)
class ProductsTable extends StatelessWidget {
  final List<Map<String, dynamic>> products;
  final void Function(Map<String, dynamic> product) onEdit;
  final void Function(Map<String, dynamic> product) onDelete;
  final bool isCompact;
  const ProductsTable(this.products, {super.key, required this.onEdit, required this.onDelete, this.isCompact = false});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    if (isCompact) {
      return Column(
        children: products.map((p) {
          final img = p['image']?.toString();
          final status = p['status'] is int ? p['status'] as int : 1;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                if (img != null && img.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(img, width: 56, height: 56, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(width: 56, height: 56, color: AppColors.background)),
                  )
                else
                  Container(width: 56, height: 56, decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8))),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p['name']?.toString() ?? '—', style: appStyle(15, FontWeight.w700, AppColors.textPrimary)),
                      const SizedBox(height: 4),
                      Text(_priceText(p), style: appStyle(13, FontWeight.w600, AppColors.primary)),
                      const SizedBox(height: 2),
                      Text('${t.tr('category')}: ${p['category']?.toString() ?? '—'} • ${t.tr('qty')}: ${p['qty'] ?? 0}',
                          style: appStyle(12, FontWeight.w400, AppColors.textSecondary)),
                    ],
                  ),
                ),
                Column(
                  children: [
                    IconButton(onPressed: () => onEdit(p), icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary)),
                    IconButton(onPressed: () => onDelete(p), icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error)),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      );
    }
    final columns = [t.tr('image'), t.tr('name'), t.tr('category'), t.tr('price'), t.tr('qty'), t.tr('status'), t.tr('actions')];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: columns.map((c) => DataColumn(label: Text(c, style: appStyle(13, FontWeight.w600, AppColors.textSecondary)))).toList(),
          rows: products.map((p) {
            final img = p['image']?.toString();
            final status = p['status'] is int ? p['status'] as int : 1;
            final statusText = status == 1 ? t.tr('active') : t.tr('inactive');
            return DataRow(cells: [
              DataCell(img != null && img.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(img, width: 40, height: 40, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(width: 40, height: 40, color: AppColors.background)),
                    )
                  : Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(6)))),
              DataCell(Text(p['name']?.toString() ?? '—', style: appStyle(14, FontWeight.w500, AppColors.textPrimary))),
              DataCell(Text(p['category']?.toString() ?? '—', style: appStyle(14, FontWeight.w400, AppColors.textSecondary))),
              DataCell(Text(_priceText(p), style: appStyle(14, FontWeight.w600, AppColors.primary))),
              DataCell(Text('${p['qty'] ?? 0}', style: appStyle(14, FontWeight.w400, AppColors.textSecondary))),
              DataCell(Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: status == 1 ? AppColors.success.withValues(alpha: 0.12) : AppColors.textDisabled.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(statusText, style: appStyle(12, FontWeight.w600, status == 1 ? AppColors.success : AppColors.textSecondary)),
              )),
              DataCell(Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(onPressed: () => onEdit(p), icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary), tooltip: t.tr('edit')),
                  IconButton(onPressed: () => onDelete(p), icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error), tooltip: t.tr('delete')),
                ],
              )),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
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
          Text(message, style: appStyle(14, FontWeight.w500, AppColors.textSecondary)),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: () => context.read<AdminProductsCubit>().loadProducts(), child: Text(t.tr('retry'))),
        ],
      ),
    );
  }
}
