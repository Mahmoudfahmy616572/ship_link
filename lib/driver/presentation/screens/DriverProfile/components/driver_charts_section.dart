import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/driver/data/repositories/driver_earnings_repository_impl.dart';
import 'package:dartz/dartz.dart' hide State;
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/utils/sizer.dart';
import 'package:ship_link/core/widgets/app_style.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DriverChartsSection extends StatefulWidget {
  const DriverChartsSection({super.key});

  @override
  State<DriverChartsSection> createState() => _DriverChartsSectionState();
}

class _DriverChartsSectionState extends State<DriverChartsSection> {
  final _dailyEarnings = ValueNotifier<List<double>>([]);
  final _statusCounts = ValueNotifier<Map<String, int>>({});
  final _loading = ValueNotifier<bool>(true);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _dailyEarnings.dispose();
    _statusCounts.dispose();
    _loading.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final driverId = Supabase.instance.client.auth.currentUser?.id;
    if (driverId == null) return;
    final svc = DriverEarningsRepositoryImpl();
    final daily = (await svc.getDailyEarnings(driverId, days: 7)).fold((_) => <double>[], (v) => v);
    final statuses = (await svc.getOrderStatusCounts(driverId)).fold((_) => <String, int>{}, (v) => v);
    _dailyEarnings.value = daily;
    _statusCounts.value = statuses;
    _loading.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _loading,
      builder: (context, loading, _) {
        if (loading) return SizedBox(height: 200, child: Center(child: CircularProgressIndicator(strokeWidth: 2)));

        return ValueListenableBuilder<List<double>>(
          valueListenable: _dailyEarnings,
          builder: (context, dailyEarnings, _) {
            return ValueListenableBuilder<Map<String, int>>(
              valueListenable: _statusCounts,
              builder: (context, statusCounts, _) {
                final dayNames = List.generate(7, (i) {
                  final d = DateTime.now().subtract(Duration(days: 6 - i));
                  final abbr = [context.t.tr('mon'), context.t.tr('tue'), context.t.tr('wed'), context.t.tr('thu'), context.t.tr('fri'), context.t.tr('sat'), context.t.tr('sun')];
                  return abbr[d.weekday - 1];
                });

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.t.tr('earnings_overview'), style: appStyle(18, FontWeight.w700, AppColors.textPrimary)),
                    SizedBox(height: 16.h),
                    SizedBox(
                      height: 200.h,
                      child: BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: (dailyEarnings.isEmpty ? 10.0 : (dailyEarnings.reduce((a, b) => a > b ? a : b) * 1.3)).clamp(10.0, double.infinity),
                          barTouchData: BarTouchData(enabled: true),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) {
                              final i = v.toInt();
                              if (i < 0 || i >= dayNames.length) return const SizedBox.shrink();
                              return Text(dayNames[i], style: appStyle(10, FontWeight.w400, AppColors.textSecondary));
                            })),
                            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (v, _) {
                              return Text('\$${v.toInt()}', style: appStyle(10, FontWeight.w400, AppColors.textSecondary));
                            })),
                            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(show: false),
                          gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 20),
                          barGroups: List.generate(dailyEarnings.length, (i) {
                            return BarChartGroupData(x: i, barRods: [
                              BarChartRodData(toY: dailyEarnings[i], color: AppColors.cta, width: 16.w, borderRadius: BorderRadius.circular(4)),
                            ]);
                          }),
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    if (statusCounts.isNotEmpty) ...[
                      Text(context.t.tr('order_status_distribution'), style: appStyle(18, FontWeight.w700, AppColors.textPrimary)),
                      SizedBox(height: 16.h),
                      SizedBox(
                        height: 180.h,
                        child: PieChart(
                          PieChartData(
                            sections: _buildPieSections(statusCounts),
                            centerSpaceRadius: 40,
                            sectionsSpace: 2,
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      _buildLegend(statusCounts),
                    ],
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  static const _statusColors = {
    'delivered': Color(0xFF22C55E),
    'accepted': Color(0xFF3B82F6),
    'picked_up': Color(0xFFF59E0B),
    'shipped': Color(0xFF8B5CF6),
    'pending': Color(0xFF9CA3AF),
    'cancelled': Color(0xFFEF4444),
  };

  Widget _buildLegend(Map<String, int> statusCounts) {
    final total = statusCounts.values.fold(0, (a, b) => a + b);
    if (total == 0) return const SizedBox.shrink();
    final entries = statusCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Wrap(
      spacing: 16.w,
      runSpacing: 8.h,
      children: entries.map((e) {
        final pct = (e.value / total * 100).toStringAsFixed(0);
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10.w, height: 10.h,
              decoration: BoxDecoration(
                color: _statusColors[e.key] ?? Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 6.w),
            Text('${_statusLabel(e.key)} ($pct%)',
                style: appStyle(12, FontWeight.w500, AppColors.textSecondary)),
          ],
        );
      }).toList(),
    );
  }

  String _statusLabel(String key) {
    switch (key) {
      case 'delivered': return context.t.tr('delivered');
      case 'accepted': return context.t.tr('accepted');
      case 'picked_up': return context.t.tr('picked_up');
      case 'shipped': return context.t.tr('in_transit');
      case 'pending': return context.t.tr('pending');
      case 'cancelled': return context.t.tr('cancelled');
      default: return key;
    }
  }

  List<PieChartSectionData> _buildPieSections(Map<String, int> statusCounts) {
    final total = statusCounts.values.fold(0, (a, b) => a + b);
    if (total == 0) return [];
    return statusCounts.entries.map((e) {
      final pct = (e.value / total * 100).toStringAsFixed(0);
      return PieChartSectionData(
        value: e.value.toDouble(),
        color: _statusColors[e.key] ?? Colors.grey,
        title: '$pct%',
        titleStyle: appStyle(12, FontWeight.w700, Colors.white),
        radius: 50,
      );
    }).toList();
  }
}
