import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
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
    final period = stats['period']?.toString() ?? 'all';
    final periodLabel = period == 'daily'
        ? t.tr('today')
        : period == 'weekly'
            ? t.tr('this_week')
            : period == 'monthly'
                ? t.tr('this_month')
                : t.tr('total');

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
            AdminStatCard(
              title: '${t.tr('revenue')} ($periodLabel)',
              value: '${revenue.toStringAsFixed(0)} EGP',
              icon: Icons.payments_outlined,
              color: AppColors.success,
            ),
          ],
        );
      },
    );
  }
}

// شارت اتجاه الطلبات (آخر 7 أيام)
class OrderTrendChart extends StatelessWidget {
  final Map<String, dynamic> trend;
  const OrderTrendChart(this.trend, {super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    if (trend.isEmpty) {
      return Container(
        height: 220,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Center(child: Text(t.tr('no_results'), style: appStyle(14, FontWeight.w400, AppColors.textSecondary))),
      );
    }

    // نجهز نقاط آخر 7 أيام
    final now = DateTime.now();
    final spots = <FlSpot>[];
    final labels = <String>[];
    for (int i = 6; i >= 0; i--) {
      final d = now.subtract(Duration(days: i));
      final key = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      final count = (trend[key] is int ? trend[key] as int : 0).toDouble();
      spots.add(FlSpot((6 - i).toDouble(), count));
      labels.add('${d.day}/${d.month}');
    }
    final maxY = spots.map((s) => s.y).fold(0.0, (a, b) => a > b ? a : b);
    final roundedMax = ((maxY == 0 ? 5.0 : maxY) + 1).toDouble();

    return Container(
      height: 240,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t.tr('orders_trend'), style: appStyle(15, FontWeight.w600, AppColors.textPrimary)),
          const SizedBox(height: 12),
          Expanded(
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: roundedMax,
                gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 1),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        final idx = v.toInt();
                        if (idx < 0 || idx >= labels.length) return const Text('');
                        return Text(labels[idx], style: appStyle(10, FontWeight.w400, AppColors.textSecondary));
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, interval: 1, getTitlesWidget: (v, _) => Text(v.toInt().toString(), style: appStyle(10, FontWeight.w400, AppColors.textSecondary))),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(show: true, color: AppColors.primary.withValues(alpha: 0.1)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
