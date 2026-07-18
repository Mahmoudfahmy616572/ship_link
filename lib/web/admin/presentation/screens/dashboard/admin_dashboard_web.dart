import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/widgets/app_style.dart';
import 'package:ship_link/core/utils/sizer.dart';
import 'package:ship_link/web/admin/presentation/cubits/dashboard/admin_dashboard_cubit.dart';
import 'package:ship_link/web/admin/presentation/screens/dashboard/widgets/dashboard_widgets.dart';

// شاشة نظرة عامة على اللوحة (إحصائيات + توزيع حالات الطلبات)
class AdminDashboardWeb extends StatelessWidget {
  const AdminDashboardWeb({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return BlocBuilder<AdminDashboardCubit, dynamic>(
      builder: (context, state) {
        if (state is AdminDashboardInitial) {
          context.read<AdminDashboardCubit>().loadStats();
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
                onPressed: () => context.read<AdminDashboardCubit>().loadStats(),
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

        return SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t.tr('dashboard_overview'), style: appStyle(22, FontWeight.w700, AppColors.textPrimary)),
              SizedBox(height: 20.h),
              DashboardStatGrid(s),
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
}
