import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:ship_link/constant/colors.dart';
import 'package:ship_link/data/services/driverEarnings/driver_earnings_service.dart';
import 'package:ship_link/localization.dart';
import 'package:ship_link/utils/sizer.dart';
import 'package:ship_link/views/shared/app_style.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DriverChartsSection extends StatefulWidget {
  const DriverChartsSection({super.key});

  @override
  State<DriverChartsSection> createState() => _DriverChartsSectionState();
}

class _DriverChartsSectionState extends State<DriverChartsSection> {
  List<double> _dailyEarnings = [];
  Map<String, int> _statusCounts = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final driverId = Supabase.instance.client.auth.currentUser?.id;
    if (driverId == null) return;
    final svc = DriverEarningsService(Supabase.instance.client);
    final daily = await svc.getDailyEarnings(driverId, days: 7);
    final statuses = await svc.getOrderStatusCounts(driverId);
    if (mounted) setState(() { _dailyEarnings = daily; _statusCounts = statuses; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return SizedBox(height: 200, child: Center(child: CircularProgressIndicator(strokeWidth: 2)));

    final dayNames = List.generate(7, (i) {
      final d = DateTime.now().subtract(Duration(days: 6 - i));
      const abbr = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
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
              maxY: (_dailyEarnings.isEmpty ? 10.0 : (_dailyEarnings.reduce((a, b) => a > b ? a : b) * 1.3)).clamp(10.0, double.infinity),
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
              barGroups: List.generate(_dailyEarnings.length, (i) {
                return BarChartGroupData(x: i, barRods: [
                  BarChartRodData(toY: _dailyEarnings[i], color: AppColors.cta, width: 16.w, borderRadius: BorderRadius.circular(4)),
                ]);
              }),
            ),
          ),
        ),
        SizedBox(height: 24.h),
        if (_statusCounts.isNotEmpty) ...[
          Text(context.t.tr('order_status_distribution'), style: appStyle(18, FontWeight.w700, AppColors.textPrimary)),
          SizedBox(height: 16.h),
          SizedBox(
            height: 180.h,
            child: PieChart(
              PieChartData(
                sections: _buildPieSections(),
                centerSpaceRadius: 40,
                sectionsSpace: 2,
              ),
            ),
          ),
        ],
      ],
    );
  }

  List<PieChartSectionData> _buildPieSections() {
    final total = _statusCounts.values.fold(0, (a, b) => a + b);
    if (total == 0) return [];
    const colors = {
      'delivered': Color(0xFF22C55E),
      'accepted': Color(0xFF3B82F6),
      'picked_up': Color(0xFFF59E0B),
      'shipped': Color(0xFF8B5CF6),
      'pending': Color(0xFF9CA3AF),
      'cancelled': Color(0xFFEF4444),
    };
    return _statusCounts.entries.map((e) {
      final pct = (e.value / total * 100).toStringAsFixed(0);
      return PieChartSectionData(
        value: e.value.toDouble(),
        color: colors[e.key] ?? Colors.grey,
        title: '$pct%',
        titleStyle: appStyle(12, FontWeight.w700, Colors.white),
        radius: 50,
      );
    }).toList();
  }
}
