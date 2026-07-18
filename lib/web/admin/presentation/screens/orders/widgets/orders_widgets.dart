import 'package:flutter/material.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/widgets/app_style.dart';
import 'package:ship_link/core/utils/sizer.dart';

// بادج حالة الطلب ملون حسب الحالة
class OrderStatusChip extends StatelessWidget {
  final String status;
  const OrderStatusChip(this.status, {super.key});

  static Color colorFor(String status) {
    switch (status) {
      case 'pending': return AppColors.pending;
      case 'confirmed': return AppColors.primary;
      case 'shipped': return AppColors.info;
      case 'delivered': return AppColors.success;
      case 'cancelled': return AppColors.error;
      default: return const Color(0xFF9CA3AF);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = colorFor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(status.toUpperCase(), style: appStyle(12, FontWeight.w600, color)),
    );
  }
}

// جدول الطلبات (كل صف فيه زر يفتح التفاصيل)
class OrdersTable extends StatelessWidget {
  final List<Map<String, dynamic>> orders;
  final void Function(Map<String, dynamic> order) onOpenDetail;
  final bool isCompact;
  const OrdersTable(this.orders, {super.key, required this.onOpenDetail, this.isCompact = false});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    if (isCompact) {
      return Column(
        children: orders.map((o) {
          final total = (o['total_price'] is num ? (o['total_price'] as num).toDouble() : 0.0);
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: InkWell(
              onTap: () => onOpenDetail(o),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('#${o['id']}', style: appStyle(15, FontWeight.w700, AppColors.textPrimary)),
                      OrderStatusChip(o['status']?.toString() ?? 'unknown'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('${t.tr('customer')}: ${o['user_id']?.toString().substring(0, 8) ?? '—'}',
                      style: appStyle(13, FontWeight.w400, AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${total.toStringAsFixed(0)} EGP', style: appStyle(14, FontWeight.w600, AppColors.textPrimary)),
                      TextButton.icon(
                        onPressed: () => onOpenDetail(o),
                        icon: const Icon(Icons.visibility_outlined, size: 16),
                        label: Text(t.tr('details')),
                        style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      );
    }
    final columns = [t.tr('order_no'), t.tr('customer'), t.tr('total'), t.tr('status'), t.tr('details')];
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
          rows: orders.map((o) {
            final total = (o['total_price'] is num ? (o['total_price'] as num).toDouble() : 0.0);
            return DataRow(cells: [
              DataCell(Text('#${o['id']}', style: appStyle(14, FontWeight.w600, AppColors.textPrimary))),
              DataCell(Text(o['user_id']?.toString().substring(0, 8) ?? '—', style: appStyle(14, FontWeight.w400, AppColors.textSecondary))),
              DataCell(Text('${total.toStringAsFixed(0)} EGP', style: appStyle(14, FontWeight.w500, AppColors.textPrimary))),
              DataCell(OrderStatusChip(o['status']?.toString() ?? 'unknown')),
              DataCell(
                TextButton.icon(
                  onPressed: () => onOpenDetail(o),
                  icon: const Icon(Icons.visibility_outlined, size: 16),
                  label: Text(t.tr('details')),
                  style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                ),
              ),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}

// هيدر بيانات الأوردر (رقم، عميل، مجموع، حالة) في شاشة التفاصيل
class OrderHeader extends StatelessWidget {
  final Map<String, dynamic> order;
  const OrderHeader({required this.order});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final total = (order['total_price'] is num ? (order['total_price'] as num).toDouble() : 0.0);
    final customer = order['customer_name']?.toString() ?? order['user_id']?.toString().substring(0, 8) ?? '—';
    final status = order['status']?.toString() ?? 'unknown';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(t.tr('customer'), style: appStyle(12, FontWeight.w400, AppColors.textSecondary)),
              SizedBox(height: 4.h),
              Text(customer, style: appStyle(15, FontWeight.w600, AppColors.textPrimary)),
            ]),
          ),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(t.tr('total'), style: appStyle(12, FontWeight.w400, AppColors.textSecondary)),
              SizedBox(height: 4.h),
              Text('${total.toStringAsFixed(0)} EGP', style: appStyle(15, FontWeight.w600, AppColors.textPrimary)),
            ]),
          ),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(t.tr('status'), style: appStyle(12, FontWeight.w400, AppColors.textSecondary)),
              SizedBox(height: 4.h),
              OrderStatusChip(status),
            ]),
          ),
        ],
      ),
    );
  }
}

// قائمة منتجات الطلب في شاشة التفاصيل
class OrderItemsList extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  const OrderItemsList(this.items, {super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    if (items.isEmpty) {
      return Text(t.tr('no_results'), style: appStyle(14, FontWeight.w400, AppColors.textSecondary));
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: items.map((it) {
          final product = it['products'] is Map ? it['products'] as Map : <String, dynamic>{};
          final name = product['name']?.toString() ?? '—';
          final price = (product['price'] is num ? (product['price'] as num).toDouble() : 0.0);
          final qty = it['quantity'] is int ? it['quantity'] as int : 1;
          return ListTile(
            title: Text(name, style: appStyle(14, FontWeight.w500, AppColors.textPrimary)),
            subtitle: Text('${price.toStringAsFixed(0)} EGP', style: appStyle(12, FontWeight.w400, AppColors.textSecondary)),
            trailing: Text('x$qty', style: appStyle(14, FontWeight.w600, AppColors.textPrimary)),
          );
        }).toList(),
      ),
    );
  }
}

// صفحة الخطأ
class OrdersErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const OrdersErrorView(this.message, this.onRetry, {super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(message, style: appStyle(15, FontWeight.w500, AppColors.error)),
        SizedBox(height: 12.h),
        ElevatedButton(onPressed: onRetry, child: Text(t.tr('retry'))),
      ]),
    );
  }
}

// الـ loading بتاع الجدول
class OrdersTableShimmer extends StatelessWidget {
  const OrdersTableShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: 6,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(height: 64, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12))),
      ),
    );
  }
}
