import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/services/supabase_service.dart';
import 'package:ship_link/core/widgets/app_style.dart';
import 'package:ship_link/core/widgets/shimmer/shimmer_loading.dart';
import 'package:ship_link/admin/widgets/admin_stats_card.dart';
import 'package:ship_link/core/utils/sizer.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});
  static String routName = '/admin/dashboard';

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final _supabase = SupabaseService();
  bool _loading = true;
  int _totalOrders = 0;
  int _pendingOrders = 0;
  int _deliveredOrders = 0;
  int _cancelledOrders = 0;
  int _totalProducts = 0;
  int _totalDrivers = 0;
  int _totalUsers = 0;
  num _totalRevenue = 0;
  List<Map<String, dynamic>> _recentOrders = [];

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    final orders = await _supabase.getOrders();
    final products = await _supabase.getProducts();
    final drivers = await _supabase.getProfilesByRole('driver');
    final users = await _supabase.getProfilesByRole('user');
    final recent = await _supabase.getOrdersGroupedByDate(days: 7);

    num totalRev = 0;
    int pending = 0, delivered = 0, cancelled = 0;
    for (final o in orders) {
      totalRev += (o['total_price'] as num? ?? 0);
      switch (o['status'] as String?) {
        case 'pending':   pending++; break;
        case 'delivered': delivered++; break;
        case 'cancelled': cancelled++; break;
      }
    }

    setState(() {
      _totalOrders = orders.length;
      _pendingOrders = pending;
      _deliveredOrders = delivered;
      _cancelledOrders = cancelled;
      _totalProducts = products.length;
      _totalDrivers = drivers.length;
      _totalUsers = users.length;
      _totalRevenue = totalRev;
      _recentOrders = recent;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    if (_loading) {
      return SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(children: [
          ShimmerLoading.list(itemCount: 4),
          SizedBox(height: 20.h),
          ShimmerLoading.productDetail(),
        ]),
      );
    }

    final orders = [
      ('Pending', _pendingOrders, AppColors.pending, Icons.pending_actions),
      ('Delivered', _deliveredOrders, AppColors.success, Icons.check_circle),
      ('Cancelled', _cancelledOrders, AppColors.error, Icons.cancel),
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats cards row
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              SizedBox(
                width: isWide ? 220 : double.infinity,
                child: AdminStatsCard(
                  title: 'Total Orders',
                  value: '$_totalOrders',
                  icon: Icons.receipt_long,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(
                width: isWide ? 220 : double.infinity,
                child: AdminStatsCard(
                  title: 'Revenue',
                  value: '\$${_totalRevenue.toStringAsFixed(0)}',
                  icon: Icons.attach_money,
                  color: AppColors.success,
                ),
              ),
              SizedBox(
                width: isWide ? 220 : double.infinity,
                child: AdminStatsCard(
                  title: 'Drivers',
                  value: '$_totalDrivers',
                  icon: Icons.local_shipping,
                  color: Colors.purple,
                ),
              ),
              SizedBox(
                width: isWide ? 220 : double.infinity,
                child: AdminStatsCard(
                  title: 'Products',
                  value: '$_totalProducts',
                  icon: Icons.inventory_2,
                  color: AppColors.info,
                ),
              ),
              SizedBox(
                width: isWide ? 220 : double.infinity,
                child: AdminStatsCard(
                  title: 'Users',
                  value: '$_totalUsers',
                  icon: Icons.people,
                  color: AppColors.cta,
                ),
              ),
            ],
          ),

          SizedBox(height: 24.h),

          // Charts row
          isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildRevenueChart()),
                    SizedBox(width: 16.w),
                    SizedBox(width: 320.w, child: _buildStatusPieChart(orders)),
                  ],
                )
              : Column(
                  children: [
                    _buildRevenueChart(),
                    SizedBox(height: 16.h),
                    _buildStatusPieChart(orders),
                  ],
                ),

          SizedBox(height: 24.h),

          // Recent orders summary
          _buildRecentOrders(),
        ],
      ),
    );
  }

  Widget _buildRecentOrders() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recent Orders', style: appStyle(16, FontWeight.bold, AppColors.textPrimary)),
          SizedBox(height: 12.h),
          ...(_recentOrders.isEmpty
              ? [Padding(padding: EdgeInsets.all(16.w), child: Center(child: Text('No orders in last 7 days', style: appStyle(14, FontWeight.w400, AppColors.textHint))))]
              : _recentOrders.take(5).map((o) => Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.h),
                    child: Row(
                      children: [
                        Text('#${o['id']}', style: appStyle(13, FontWeight.w600, AppColors.textPrimary)),
                        const Spacer(),
                        Text('\$${o['total_price']}', style: appStyle(13, FontWeight.w600, AppColors.cta)),
                        SizedBox(width: 12.w),
                        _statusChip(o['status'] ?? ''),
                      ],
                    ),
                  ))),
        ],
      ),
    );
  }

  Widget _buildRevenueChart() {
    final Map<String, num> dayTotals = {};
    for (final o in _recentOrders) {
      final date = o['created_at'] as String? ?? '';
      final day = date.length >= 10 ? date.substring(0, 10) : 'Unknown';
      dayTotals[day] = (dayTotals[day] ?? 0) + (o['total_price'] as num? ?? 0);
    }

    if (dayTotals.isEmpty) {
      return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        height: 240,
        child: Center(child: Text('No revenue data', style: appStyle(14, FontWeight.w400, AppColors.textHint))),
      );
    }

    final sortedDays = dayTotals.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    final maxVal = dayTotals.values.fold<num>(0, (a, b) => max(a, b));

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      height: 240,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Revenue (7 days)', style: appStyle(14, FontWeight.bold, AppColors.textPrimary)),
          SizedBox(height: 12.h),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (maxVal * 1.2).toDouble().clamp(10, double.infinity),
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (v, _) => Text('\$${v.toInt()}', style: appStyle(10, FontWeight.w400, AppColors.textHint))),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) {
                      final i = v.toInt();
                      if (i < 0 || i >= sortedDays.length) return const SizedBox.shrink();
                      final day = sortedDays[i].key;
                      return Text(day.substring(5), style: appStyle(10, FontWeight.w400, AppColors.textHint));
                    }),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                barGroups: sortedDays.asMap().entries.map((e) {
                  final dayVal = e.value.value.toDouble();
                  return BarChartGroupData(x: e.key, barRods: [
                    BarChartRodData(toY: dayVal, color: AppColors.cta, width: 16, borderRadius: BorderRadius.vertical(top: Radius.circular(4.r))),
                  ]);
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPieChart(List<(String, int, Color, IconData)> orders) {
    final total = orders.fold<int>(0, (s, e) => s + e.$2);
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      height: 240,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Order Status', style: appStyle(14, FontWeight.bold, AppColors.textPrimary)),
          SizedBox(height: 8.h),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 30,
                      sections: orders.where((e) => e.$2 > 0).map((e) {
                        return PieChartSectionData(
                          value: e.$2.toDouble(),
                          color: e.$3,
                          radius: 36,
                          title: total > 0 ? '${(e.$2 / total * 100).toStringAsFixed(0)}%' : '0%',
                          titleStyle: appStyle(11, FontWeight.bold, Colors.white),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: orders.map((e) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 3.h),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(width: 10.w, height: 10.h, decoration: BoxDecoration(color: e.$3, shape: BoxShape.circle)),
                          SizedBox(width: 6.w),
                          Text('${e.$1} (${e.$2})', style: appStyle(12, FontWeight.w500, AppColors.textPrimary)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    Color color;
    switch (status) {
      case 'pending':   color = AppColors.pending; break;
      case 'delivered': color = AppColors.success; break;
      case 'cancelled': color = AppColors.error; break;
      default:          color = AppColors.textHint;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(color: color.withAlpha(25), borderRadius: BorderRadius.circular(10.r)),
      child: Text(status, style: appStyle(11, FontWeight.w500, color)),
    );
  }
}