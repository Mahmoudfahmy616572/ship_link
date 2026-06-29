import 'package:flutter/material.dart';
import 'package:ship_link/utils/sizer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/constant/colors.dart';
import 'package:ship_link/constant/services_locators.dart';
import 'package:ship_link/cubits/orderHistory/order_history_cubit.dart';
import 'package:ship_link/data/services/cartServeices/cart_serveicesimpl.dart';
import 'package:ship_link/localization.dart';
import 'package:ship_link/views/shared/app_style.dart';
import 'package:ship_link/views/shared/shimmer/shimmer_loading.dart';

class OrderHistory extends StatelessWidget {
  const OrderHistory({super.key});
  static String routName = '/orderHistory';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OrderHistoryCubit(
        getIt.get<CartServeicesImpl>(),
      )..loadOrders(),
      child: _OrderHistoryBody(),
    );
  }
}

class _OrderHistoryBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(context.t.tr('order_history'), style: appStyle(20, FontWeight.bold, AppColors.textPrimary)),
      ),
      body: BlocBuilder<OrderHistoryCubit, OrderHistoryState>(
        builder: (context, state) {
          if (state is OrderHistoryLoading) {
            return ShimmerLoading.orderHistory();
          }
          if (state is OrderHistoryError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.message, style: appStyle(14, FontWeight.w400, AppColors.textSecondary)),
                  SizedBox(height: 12.h),
                  ElevatedButton(
                    onPressed: () => context.read<OrderHistoryCubit>().loadOrders(),
                    child: Text(context.t.tr('retry')),
                  ),
                ],
              ),
            );
          }
          if (state is OrderHistoryLoaded) {
            if (state.orders.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.receipt_long, size: 64.sp, color: AppColors.textHint),
                    SizedBox(height: 16.h),
                    Text(context.t.tr('no_orders_yet'), style: appStyle(16, FontWeight.w500, AppColors.textSecondary)),
                    SizedBox(height: 8.h),
                    Text(context.t.tr('no_orders_hint'),
                        style: appStyle(13, FontWeight.w400, AppColors.textHint)),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              itemCount: state.orders.length,
              itemBuilder: (context, index) {
                final order = state.orders[index];
                final id = order['id'] ?? 0;
                final total = order['total_price'] ?? 0;
                final status = order['status'] ?? 'pending';
                final createdAt = order['created_at'] ?? '';
                final date = createdAt is String && createdAt.length >= 10
                    ? createdAt.substring(0, 10)
                    : '';

                final Color statusColor;
                switch (status.toString()) {
                  case 'pending':
                    statusColor = AppColors.pending;
                    break;
                  case 'confirmed':
                    statusColor = AppColors.info;
                    break;
                  case 'delivered':
                    statusColor = AppColors.success;
                    break;
                  case 'cancelled':
                    statusColor = AppColors.error;
                    break;
                  default:
                    statusColor = AppColors.textHint;
                }

                return GestureDetector(
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/orderDetail',
                    arguments: id,
                  ),
                  child: Card(
                  margin: EdgeInsets.only(bottom: 8.h),
                  color: AppColors.surface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: EdgeInsets.all(14.w),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10.w),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(25),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.receipt, color: AppColors.primary, size: 24),
                        ),
                        SizedBox(width: 14.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${context.t.tr('order_no')} #$id',
                                  style: appStyle(15, FontWeight.w600, AppColors.textPrimary)),
                              SizedBox(height: 4.h),
                              Text(date, style: appStyle(12, FontWeight.w400, AppColors.textHint)),
                              SizedBox(height: 2.h),
                              Text("\$$total",
                                  style: appStyle(15, FontWeight.w700, AppColors.cta)),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: statusColor.withAlpha(25),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            status.toString(),
                            style: appStyle(12, FontWeight.w600, statusColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
