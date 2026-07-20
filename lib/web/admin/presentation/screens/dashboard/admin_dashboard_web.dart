import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/widgets/app_style.dart';
import 'package:ship_link/core/utils/sizer.dart';
import 'package:ship_link/web/admin/presentation/cubits/dashboard/admin_dashboard_cubit.dart';
import 'package:ship_link/web/admin/presentation/screens/dashboard/widgets/dashboard_widgets.dart';
import 'package:ship_link/web/admin/presentation/screens/shared/admin_theme_mode.dart';
import 'package:ship_link/web/admin/presentation/screens/shared/admin_toast.dart';

// شاشة نظرة عامة على اللوحة (إحصائيات + توزيع حالات الطلبات)
class AdminDashboardWeb extends StatefulWidget {
  const AdminDashboardWeb({super.key});

  @override
  State<AdminDashboardWeb> createState() => _AdminDashboardWebState();
}

class _AdminDashboardWebState extends State<AdminDashboardWeb> {
  String _period = 'all';

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final isDark = AdminThemeMode.isDark.value;
    final textPrimary = AdminThemeMode.textPrimary(isDark);
    return BlocBuilder<AdminDashboardCubit, dynamic>(
      builder: (context, state) {
        if (state is AdminDashboardInitial) {
          context.read<AdminDashboardCubit>().loadStats(period: _period);
          return const Center(child: CircularProgressIndicator());
        }
        if (state is AdminDashboardLoading) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.tr('dashboard_overview'), style: appStyle(22, FontWeight.w700, textPrimary)),
                SizedBox(height: 20.h),
                const DashboardStatGridShimmer(),
              ],
            ),
          );
        }
        if (state is AdminDashboardError) {
          return Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(state.message, style: appStyle(15, FontWeight.w500, AppColors.error)),
              SizedBox(height: 12.h),
              ElevatedButton(
                onPressed: () => context.read<AdminDashboardCubit>().loadStats(period: _period),
                child: Text(t.tr('retry')),
              ),
            ]),
          );
        }
        if (state is! AdminDashboardLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        final s = state.stats;
        final statusCounts = Map<String, dynamic>.from(s['statusCounts'] ?? {});
        final trend = Map<String, dynamic>.from(s['trend'] ?? {});
        final period = s['period']?.toString() ?? 'all';
        final periodLabel = period == 'daily'
            ? t.tr('today')
            : period == 'weekly'
                ? t.tr('this_week')
                : period == 'monthly'
                    ? t.tr('this_month')
                    : t.tr('total');
        final revenue = (s['revenue'] is num ? (s['revenue'] as num).toDouble() : 0.0);
        final growth = (s['growth'] is num ? (s['growth'] as num).toDouble() : 0.0);
        final recentOrders = (s['recentOrders'] is List) ? List<dynamic>.from(s['recentOrders']) : <dynamic>[];
        final recentUsers = (s['recentUsers'] is List) ? List<dynamic>.from(s['recentUsers']) : <dynamic>[];
        final topProducts = (s['topProducts'] is List) ? List<dynamic>.from(s['topProducts']) : <dynamic>[];
        final alerts = (s['alerts'] is List) ? List<dynamic>.from(s['alerts']) : <dynamic>[];

        return SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(t.tr('dashboard_overview'), style: appStyle(22, FontWeight.w700, textPrimary)),
                  ElevatedButton.icon(
                    onPressed: () => _exportCsv(context, s),
                    icon: const Icon(Icons.download_outlined, size: 18),
                    label: Text(t.tr('export_csv')),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              // فلتر المدة
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _PeriodChip(label: t.tr('all'), selected: _period == 'all', onTap: () => _changePeriod(context, 'all')),
                  _PeriodChip(label: t.tr('today'), selected: _period == 'daily', onTap: () => _changePeriod(context, 'daily')),
                  _PeriodChip(label: t.tr('this_week'), selected: _period == 'weekly', onTap: () => _changePeriod(context, 'weekly')),
                  _PeriodChip(label: t.tr('this_month'), selected: _period == 'monthly', onTap: () => _changePeriod(context, 'monthly')),
                ],
              ),
              SizedBox(height: 20.h),
              // الصف الأول: كارت الإيراد + شبكة الإحصائيات
              LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth > 900;
                  return wide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 2, child: RevenueCard(revenue: revenue, growth: growth, isDark: isDark, periodLabel: periodLabel)),
                            const SizedBox(width: 16),
                            Expanded(flex: 3, child: DashboardStatGrid(s, isDark: isDark)),
                          ],
                        )
                      : Column(
                          children: [
                            RevenueCard(revenue: revenue, growth: growth, isDark: isDark, periodLabel: periodLabel),
                            const SizedBox(height: 16),
                            DashboardStatGrid(s, isDark: isDark),
                          ],
                        );
                },
              ),
              SizedBox(height: 28.h),
              // التنبيهات
              Text(t.tr('alerts'), style: appStyle(18, FontWeight.w600, textPrimary)),
              SizedBox(height: 12.h),
              DashboardAlerts(alerts: alerts, isDark: isDark),
              SizedBox(height: 28.h),
              // الصف التاني: شارت المبيعات + توزيع الحالات (دائري)
              LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth > 900;
                  return wide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: SalesBarChart(trend, isDark: isDark)),
                            const SizedBox(width: 16),
                            Expanded(child: OrderStatusPie(statusCounts, isDark: isDark)),
                          ],
                        )
                      : Column(
                          children: [
                            SalesBarChart(trend, isDark: isDark),
                            const SizedBox(height: 16),
                            OrderStatusPie(statusCounts, isDark: isDark),
                          ],
                        );
                },
              ),
              SizedBox(height: 28.h),
              // النشاط الأخير + أعلى المنتجات
              LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth > 900;
                  return wide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(t.tr('recent_activity'), style: appStyle(18, FontWeight.w600, textPrimary)),
                              SizedBox(height: 12.h),
                              RecentActivityFeed(recentOrders: recentOrders, recentUsers: recentUsers, isDark: isDark),
                            ])),
                            const SizedBox(width: 16),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(t.tr('top_sellers'), style: appStyle(18, FontWeight.w600, textPrimary)),
                              SizedBox(height: 12.h),
                              TopSellersList(products: topProducts, isDark: isDark),
                            ])),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t.tr('recent_activity'), style: appStyle(18, FontWeight.w600, textPrimary)),
                            SizedBox(height: 12.h),
                            RecentActivityFeed(recentOrders: recentOrders, recentUsers: recentUsers, isDark: isDark),
                            SizedBox(height: 28.h),
                            Text(t.tr('top_sellers'), style: appStyle(18, FontWeight.w600, textPrimary)),
                            SizedBox(height: 12.h),
                            TopSellersList(products: topProducts, isDark: isDark),
                          ],
                        );
                },
              ),
              SizedBox(height: 28.h),
              Text(t.tr('products_by_category'), style: appStyle(18, FontWeight.w600, textPrimary)),
              SizedBox(height: 12.h),
              ProductCategoryList(Map<String, dynamic>.from(s['productByCategory'] ?? {}), isDark: isDark),
            ],
          ),
        );
      },
    );
  }

  void _changePeriod(BuildContext context, String period) {
    setState(() => _period = period);
    context.read<AdminDashboardCubit>().loadStats(period: period);
  }

  // تصدير إحصائيات الداشبورد كملف CSV وتحميله في المتصفح
  void _exportCsv(BuildContext context, Map<String, dynamic> s) {
    final statusCounts = Map<String, dynamic>.from(s['statusCounts'] ?? {});
    final rows = <List<String>>[
      ['Metric', 'Value'],
      ['Users', '${s['users']}'],
      ['Drivers', '${s['drivers']}'],
      ['Orders', '${s['orders']}'],
      ['Products', '${s['products']}'],
      ['Revenue', '${s['revenue']}'],
      ['Growth %', '${s['growth']}'],
      ['', ''],
      ['Order Status', 'Count'],
      ...statusCounts.entries.map((e) => [e.key, '${e.value}']),
    ];
    final csv = rows.map((r) => r.map((c) => '"${c.replaceAll('"', "'")}"').join(',')).join('\n');
    final bytes = Uint8List.fromList(csv.codeUnits);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', 'dashboard_${s['period']}.csv')
      ..click();
    html.Url.revokeObjectUrl(url);
    AdminToast.show(context, context.t.tr('exported'), type: AdminToastType.success);
  }
}

// شيب فلترة المدة
class _PeriodChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _PeriodChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = AdminThemeMode.isDark.value;
    final surface = AdminThemeMode.surface(isDark);
    final border = AdminThemeMode.border(isDark);
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withValues(alpha: 0.12) : surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppColors.primary : border),
        ),
        child: Text(label, style: appStyle(13, FontWeight.w600, selected ? AppColors.primary : AdminThemeMode.textSecondary(isDark))),
      ),
    );
  }
}
