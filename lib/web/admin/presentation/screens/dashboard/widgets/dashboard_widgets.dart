import 'package:flutter/material.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/widgets/app_style.dart';
import 'package:ship_link/core/utils/sizer.dart';
import 'package:ship_link/web/admin/presentation/screens/shared/admin_stat_card.dart';

// شبكة الكروت الإحصائية فوق الداشبورد
class DashboardStatGrid extends StatelessWidget {
  final Map<String, dynamic> stats;
  const DashboardStatGrid(this.stats, {super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final revenue = (stats['revenue'] is num ? (stats['revenue'] as num).toDouble() : 0.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = constraints.maxWidth > 900 ? 4 : (constraints.maxWidth > 600 ? 2 : 1);
        return GridView.count(
          crossAxisCount: cols,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.6,
          children: [
            AdminStatCard(title: t.tr('users'), value: '${stats['users']}', icon: Icons.people_alt_rounded, color: AppColors.primary),
            AdminStatCard(title: t.tr('drivers'), value: '${stats['drivers']}', icon: Icons.local_shipping_rounded, color: AppColors.cta),
            AdminStatCard(title: t.tr('orders'), value: '${stats['orders']}', icon: Icons.receipt_long_rounded, color: AppColors.info),
            AdminStatCard(title: '${t.tr('revenue')} (EGP)', value: revenue.toStringAsFixed(0), icon: Icons.payments_outlined, color: AppColors.success),
          ],
        );
      },
    );
  }
}

// شبكة الـ loading قبل ما تجي البيانات
class DashboardStatGridShimmer extends StatelessWidget {
  const DashboardStatGridShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      childAspectRatio: 1.6,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: List.generate(4, (_) => Container(
        decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(16)),
      )),
    );
  }
}

// شيتس بتوزيع حالات الطلبات
class DashboardStatusChips extends StatelessWidget {
  final Map<String, dynamic> statusCounts;
  const DashboardStatusChips(this.statusCounts, {super.key});

  @override
  Widget build(BuildContext context) {
    final colors = {
      'pending': AppColors.pending,
      'confirmed': AppColors.primary,
      'shipped': AppColors.info,
      'delivered': AppColors.success,
      'cancelled': AppColors.error,
    };
    if (statusCounts.isEmpty) {
      return const Text('—');
    }
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: statusCounts.entries.map((e) {
        final color = colors[e.key] ?? const Color(0xFF9CA3AF);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(e.key.toUpperCase(), style: appStyle(12, FontWeight.w600, color)),
              SizedBox(height: 4.h),
              Text('${e.value}', style: appStyle(20, FontWeight.w700, AppColors.textPrimary)),
            ],
          ),
        );
      }).toList(),
    );
  }
}
