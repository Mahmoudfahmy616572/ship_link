import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/widgets/app_style.dart';
import 'package:ship_link/core/utils/sizer.dart';
import 'package:ship_link/web/admin/presentation/cubits/dashboard/admin_dashboard_cubit.dart';
import 'package:ship_link/web/admin/presentation/screens/dashboard/widgets/dashboard_widgets.dart';

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
                Text(t.tr('dashboard_overview'), style: appStyle(22, FontWeight.w700, AppColors.textPrimary)),
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

        return SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t.tr('dashboard_overview'), style: appStyle(22, FontWeight.w700, AppColors.textPrimary)),
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
              DashboardStatGrid(s),
              SizedBox(height: 28.h),
              Text(t.tr('orders_trend'), style: appStyle(18, FontWeight.w600, AppColors.textPrimary)),
              SizedBox(height: 12.h),
              OrderTrendChart(trend),
              SizedBox(height: 28.h),
              Text(t.tr('order_status_distribution'), style: appStyle(18, FontWeight.w600, AppColors.textPrimary)),
              SizedBox(height: 12.h),
              DashboardStatusChips(statusCounts),
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
}

// شيب فلترة المدة
class _PeriodChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _PeriodChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withValues(alpha: 0.12) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppColors.primary : AppColors.border),
        ),
        child: Text(label, style: appStyle(13, FontWeight.w600, selected ? AppColors.primary : AppColors.textSecondary)),
      ),
    );
  }
}
