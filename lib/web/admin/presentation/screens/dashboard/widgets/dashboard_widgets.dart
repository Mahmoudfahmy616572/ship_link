import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/widgets/app_style.dart';
import 'package:ship_link/core/utils/sizer.dart';
import 'package:ship_link/web/admin/presentation/utils/admin_date_formatter.dart';
import 'package:ship_link/web/admin/presentation/screens/shared/admin_stat_card.dart';
import 'package:ship_link/web/admin/presentation/screens/shared/admin_theme_mode.dart';

// شبكة الكروت الإحصائية فوق الداشبورد
class DashboardStatGrid extends StatelessWidget {
  final Map<String, dynamic> stats;
  final bool isDark;
  const DashboardStatGrid(this.stats, {super.key, this.isDark = false});

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
        final cols = constraints.maxWidth > 1100 ? 6 : (constraints.maxWidth > 800 ? 3 : (constraints.maxWidth > 500 ? 2 : 1));
        return GridView.count(
          crossAxisCount: cols,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.6,
          children: [
            AdminStatCard(title: t.tr('users'), value: '${stats['users']}', icon: Icons.people_alt_rounded, color: AppColors.primary, isDark: isDark),
            AdminStatCard(title: t.tr('drivers'), value: '${stats['drivers']}', icon: Icons.local_shipping_rounded, color: AppColors.cta, isDark: isDark),
            AdminStatCard(title: t.tr('orders'), value: '${stats['orders']}', icon: Icons.receipt_long_rounded, color: AppColors.info, isDark: isDark),
            AdminStatCard(title: t.tr('products'), value: '${stats['products']}', icon: Icons.inventory_2_rounded, color: AppColors.warning, isDark: isDark),
            AdminStatCard(title: t.tr('active_products'), value: '${stats['activeProducts'] ?? 0}', icon: Icons.check_circle_outline, color: AppColors.success, isDark: isDark),
            AdminStatCard(title: t.tr('low_stock'), value: '${stats['lowStock'] ?? 0}', icon: Icons.warning_amber_outlined, color: AppColors.error, isDark: isDark),
          ],
        );
      },
    );
  }
}

// شارت اتجاه الطلبات (آخر 7 أيام)
class OrderTrendChart extends StatelessWidget {
  final Map<String, dynamic> trend;
  final bool isDark;
  const OrderTrendChart(this.trend, {super.key, this.isDark = false});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final surface = AdminThemeMode.surface(isDark);
    final border = AdminThemeMode.border(isDark);
    final textPrimary = AdminThemeMode.textPrimary(isDark);
    final textSecondary = AdminThemeMode.textSecondary(isDark);
    if (trend.isEmpty) {
      return Container(
        height: 220,
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border),
        ),
        child: Center(child: Text(t.tr('no_results'), style: appStyle(14, FontWeight.w400, textSecondary))),
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
        color: surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t.tr('orders_trend'), style: appStyle(15, FontWeight.w600, textPrimary)),
          const SizedBox(height: 12),
          Expanded(
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: roundedMax,
                gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 1, getDrawingHorizontalLine: (v) => FlLine(color: border, strokeWidth: 1)),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        final idx = v.toInt();
                        if (idx < 0 || idx >= labels.length) return const Text('');
                        return Text(labels[idx], style: appStyle(10, FontWeight.w400, textSecondary));
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, interval: 1, getTitlesWidget: (v, _) => Text(v.toInt().toString(), style: appStyle(10, FontWeight.w400, textSecondary))),
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
                    belowBarData: BarAreaData(show: true, color: AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.1)),
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
  final bool isDark;
  const DashboardStatusChips(this.statusCounts, {super.key, this.isDark = false});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final textPrimary = AdminThemeMode.textPrimary(isDark);
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
              Text(t.tr(e.key), style: appStyle(12, FontWeight.w600, color)),
              SizedBox(height: 4.h),
              Text('${e.value}', style: appStyle(20, FontWeight.w700, textPrimary)),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// قائمة توزيع المنتجات حسب الفئة (شريط نسبي)
class ProductCategoryList extends StatelessWidget {
  final Map<String, dynamic> byCategory;
  final bool isDark;
  const ProductCategoryList(this.byCategory, {super.key, this.isDark = false});

  @override
  Widget build(BuildContext context) {
    final textPrimary = AdminThemeMode.textPrimary(isDark);
    final textSecondary = AdminThemeMode.textSecondary(isDark);
    final barBg = AdminThemeMode.bg(isDark);
    if (byCategory.isEmpty) {
      return Text('—', style: appStyle(14, FontWeight.w400, textSecondary));
    }
    final entries = byCategory.entries.toList()..sort((a, b) => (b.value as int).compareTo(a.value as int));
    final max = entries.map((e) => e.value as int).reduce((a, b) => a > b ? a : b).toDouble();
    final palette = [AppColors.primary, AppColors.cta, AppColors.info, AppColors.success, AppColors.warning, AppColors.error];
    return Column(
      children: entries.asMap().entries.map((e) {
        final i = e.key;
        final entry = e.value;
        final color = palette[i % palette.length];
        final pct = max > 0 ? (entry.value as int) / max : 0.0;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              SizedBox(width: 120, child: Text(entry.key, style: appStyle(14, FontWeight.w500, textPrimary), overflow: TextOverflow.ellipsis)),
              Expanded(
                child: Container(
                  height: 22,
                  decoration: BoxDecoration(color: barBg, borderRadius: BorderRadius.circular(6)),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: pct,
                    child: Container(
                      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Text('${entry.value}', style: appStyle(14, FontWeight.w700, textPrimary)),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// كارت الإيراد مع نسبة النمو مقارنة بالفترة السابقة
class RevenueCard extends StatelessWidget {
  final double revenue;
  final double growth;
  final bool isDark;
  final String periodLabel;
  const RevenueCard({super.key, required this.revenue, required this.growth, this.isDark = false, this.periodLabel = ''});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final surface = AdminThemeMode.surface(isDark);
    final border = AdminThemeMode.border(isDark);
    final textPrimary = AdminThemeMode.textPrimary(isDark);
    final textSecondary = AdminThemeMode.textSecondary(isDark);
    final up = growth >= 0;
    final growthColor = up ? AppColors.success : AppColors.error;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance_wallet_outlined, color: AppColors.success, size: 22),
              const SizedBox(width: 8),
              Text(t.tr('revenue'), style: appStyle(14, FontWeight.w500, textSecondary)),
            ],
          ),
          const SizedBox(height: 12),
          Text('EGP ${revenue.toStringAsFixed(0)}', style: appStyle(28, FontWeight.w800, textPrimary)),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(up ? Icons.arrow_upward : Icons.arrow_downward, color: growthColor, size: 16),
              const SizedBox(width: 4),
              Text('${growth.abs().toStringAsFixed(1)}%', style: appStyle(14, FontWeight.w700, growthColor)),
              const SizedBox(width: 6),
              Text('${t.tr('vs_previous')} $periodLabel', style: appStyle(12, FontWeight.w400, textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}

// شارت دائري لتوزيع حالات الطلبات
class OrderStatusPie extends StatelessWidget {
  final Map<String, dynamic> statusCounts;
  final bool isDark;
  const OrderStatusPie(this.statusCounts, {super.key, this.isDark = false});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final surface = AdminThemeMode.surface(isDark);
    final border = AdminThemeMode.border(isDark);
    final textPrimary = AdminThemeMode.textPrimary(isDark);
    final textSecondary = AdminThemeMode.textSecondary(isDark);
    if (statusCounts.isEmpty) {
      return Container(
        height: 260,
        decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: border)),
        child: Center(child: Text('—', style: appStyle(14, FontWeight.w400, textSecondary))),
      );
    }
    final colors = {
      'pending': AppColors.pending,
      'confirmed': AppColors.primary,
      'shipped': AppColors.info,
      'delivered': AppColors.success,
      'cancelled': AppColors.error,
    };
    final total = statusCounts.values.fold(0, (a, b) => a + (b as int));
    final sections = statusCounts.entries.map((e) {
      final color = colors[e.key] ?? const Color(0xFF9CA3AF);
      return PieChartSectionData(
        value: (e.value as int).toDouble(),
        title: '${((e.value as int) / (total == 0 ? 1 : total) * 100).toStringAsFixed(0)}%',
        color: color,
        radius: 80,
        titleStyle: appStyle(12, FontWeight.w700, Colors.white),
      );
    }).toList();
    return Container(
      height: 260,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: border)),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 40,
                sectionsSpace: 2,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: statusCounts.entries.map((e) {
                final color = colors[e.key] ?? const Color(0xFF9CA3AF);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
                      const SizedBox(width: 8),
                      Expanded(child: Text(t.tr(e.key), style: appStyle(12, FontWeight.w500, textSecondary), overflow: TextOverflow.ellipsis)),
                      Text('${e.value}', style: appStyle(12, FontWeight.w700, textPrimary)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// شارت عمودي للمبيعات (آخر 7 أيام)
class SalesBarChart extends StatelessWidget {
  final Map<String, dynamic> trend;
  final bool isDark;
  const SalesBarChart(this.trend, {super.key, this.isDark = false});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final surface = AdminThemeMode.surface(isDark);
    final border = AdminThemeMode.border(isDark);
    final textSecondary = AdminThemeMode.textSecondary(isDark);
    final now = DateTime.now();
    final bars = <BarChartGroupData>[];
    final labels = <String>[];
    for (int i = 6; i >= 0; i--) {
      final d = now.subtract(Duration(days: i));
      final key = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      final count = (trend[key] is int ? trend[key] as int : 0).toDouble();
      bars.add(BarChartGroupData(x: 6 - i, barRods: [BarChartRodData(toY: count, color: AppColors.primary, width: 18, borderRadius: BorderRadius.circular(4))]));
      labels.add('${d.day}/${d.month}');
    }
    return Container(
      height: 240,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t.tr('sales_last_7_days'), style: appStyle(15, FontWeight.w600, AdminThemeMode.textPrimary(isDark))),
          const SizedBox(height: 12),
          Expanded(
            child: BarChart(
              BarChartData(
                gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 1, getDrawingHorizontalLine: (v) => FlLine(color: border, strokeWidth: 1)),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) {
                    final idx = v.toInt();
                    if (idx < 0 || idx >= labels.length) return const Text('');
                    return Text(labels[idx], style: appStyle(10, FontWeight.w400, textSecondary));
                  })),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, interval: 1, getTitlesWidget: (v, _) => Text(v.toInt().toString(), style: appStyle(10, FontWeight.w400, textSecondary)))),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                barGroups: bars,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// قائمة أحدث النشاطات (طلبات + مستخدمين)
class RecentActivityFeed extends StatelessWidget {
  final List<dynamic> recentOrders;
  final List<dynamic> recentUsers;
  final bool isDark;
  const RecentActivityFeed({super.key, required this.recentOrders, required this.recentUsers, this.isDark = false});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final surface = AdminThemeMode.surface(isDark);
    final border = AdminThemeMode.border(isDark);
    final textPrimary = AdminThemeMode.textPrimary(isDark);
    final textSecondary = AdminThemeMode.textSecondary(isDark);
    final items = <Widget>[];
    for (final o in recentOrders.take(4)) {
      final status = o['status']?.toString() ?? '';
      items.add(_ActivityRow(
        icon: Icons.receipt_long_rounded,
        color: AppColors.info,
        title: '${t.tr('order')} #${o['id']}',
        subtitle: '${t.tr(status)} • EGP ${o['total_price'] ?? 0}',
        time: AdminDateFormatter.formatRelative(o['created_at']?.toString(), locale: Localizations.localeOf(context).languageCode),
        isDark: isDark,
      ));
    }
    for (final u in recentUsers.take(3)) {
      items.add(_ActivityRow(
        icon: Icons.person_add_alt_1_rounded,
        color: AppColors.success,
        title: u['name']?.toString() ?? u['email']?.toString() ?? 'User',
        subtitle: t.tr('new_user'),
        time: AdminDateFormatter.formatRelative(u['created_at']?.toString(), locale: Localizations.localeOf(context).languageCode),
        isDark: isDark,
      ));
    }
    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: border)),
        child: Center(child: Text('—', style: appStyle(14, FontWeight.w400, textSecondary))),
      );
    }
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: border)),
      child: Column(children: items),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String time;
  final bool isDark;
  const _ActivityRow({required this.icon, required this.color, required this.title, required this.subtitle, required this.time, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final textPrimary = AdminThemeMode.textPrimary(isDark);
    final textSecondary = AdminThemeMode.textSecondary(isDark);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: appStyle(14, FontWeight.w600, textPrimary), overflow: TextOverflow.ellipsis),
                Text(subtitle, style: appStyle(12, FontWeight.w400, textSecondary), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Text(time, style: appStyle(11, FontWeight.w400, textSecondary)),
        ],
      ),
    );
  }
}

// تنبيهات (مخزون قليل / طلبات معلقة / سائقين مش فعّالين)
class DashboardAlerts extends StatelessWidget {
  final List<dynamic> alerts;
  final bool isDark;
  const DashboardAlerts({super.key, required this.alerts, this.isDark = false});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final surface = AdminThemeMode.surface(isDark);
    final border = AdminThemeMode.border(isDark);
    final textPrimary = AdminThemeMode.textPrimary(isDark);
    if (alerts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: border)),
        child: Row(
          children: [
            Icon(Icons.check_circle_outline, color: AppColors.success, size: 20),
            const SizedBox(width: 10),
            Text(t.tr('all_good'), style: appStyle(14, FontWeight.w500, textPrimary)),
          ],
        ),
      );
    }
    final types = {
      'pending': AppColors.warning,
      'driver': AppColors.info,
      'stock': AppColors.error,
    };
    final icons = {
      'pending': Icons.hourglass_empty_rounded,
      'driver': Icons.local_shipping_rounded,
      'stock': Icons.inventory_2_rounded,
    };
    return Column(
      children: alerts.map((a) {
        final type = a['type']?.toString() ?? '';
        final color = types[type] ?? AppColors.warning;
        final icon = icons[type] ?? Icons.warning_amber_rounded;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Text(a['message']?.toString() ?? '', style: appStyle(14, FontWeight.w500, textPrimary))),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// قائمة أعلى المنتجات مبيعاً
class TopSellersList extends StatelessWidget {
  final List<dynamic> products;
  final bool isDark;
  const TopSellersList({super.key, required this.products, this.isDark = false});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final surface = AdminThemeMode.surface(isDark);
    final border = AdminThemeMode.border(isDark);
    final textPrimary = AdminThemeMode.textPrimary(isDark);
    final textSecondary = AdminThemeMode.textSecondary(isDark);
    if (products.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: border)),
        child: Center(child: Text('—', style: appStyle(14, FontWeight.w400, textSecondary))),
      );
    }
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: border)),
      child: Column(
        children: products.asMap().entries.map((e) {
          final p = e.value;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Row(
              children: [
                Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                  child: Center(child: Text('${e.key + 1}', style: appStyle(14, FontWeight.w700, AppColors.primary))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p['name']?.toString() ?? '—', style: appStyle(14, FontWeight.w600, textPrimary), overflow: TextOverflow.ellipsis),
                      Text(p['category']?.toString() ?? '', style: appStyle(12, FontWeight.w400, textSecondary), overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                Text('EGP ${p['price'] ?? 0}', style: appStyle(14, FontWeight.w700, textPrimary)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
