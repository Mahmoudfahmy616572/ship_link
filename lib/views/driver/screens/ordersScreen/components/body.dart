import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/constant/Errors/custom_error_widget.dart';
import 'package:ship_link/cubitDriver/getAcceptedOrders/get_accepted_order_cubit.dart';
import 'package:ship_link/cubitDriver/get_orders/get_orders_cubit.dart';
import 'package:ship_link/views/shared/app_style.dart';
import 'package:ship_link/views/shared/shimmer/shimmer_loading.dart';

import 'order_card.dart';
import 'package:ship_link/utils/sizer.dart';

class Body extends StatelessWidget {
  final int tabIndex;
  const Body({super.key, required this.tabIndex});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        if (tabIndex == 0) {
          context.read<GetOrdersCubit>().getOrder();
        } else {
          context.read<GetAcceptedOrderCubit>().getAcceptedOrder();
        }
      },
      child: () {
        switch (tabIndex) {
          case 1:
            return _buildAcceptedOrders(context);
          case 2:
            return _buildCompletedOrders(context);
          default:
            return _buildAvailableOrders(context);
        }
      }(),
    );
  }

  Widget _buildAvailableOrders(BuildContext context) {
    return BlocBuilder<GetOrdersCubit, GetOrdersState>(
      builder: (context, state) {
        if (state is GetOrdersLoading) {
          return ShimmerLoading.orderHistory();
        } else if (state is GetOrdersFailure) {
          return Center(child: CustomErrorWidget(errMessage: state.errMessage));
        } else if (state is GetOrdersSuccess) {
          final orders = state.getOrder.data?.order
              ?.where((o) => o.status?.toLowerCase() == "pending")
              .toList();
          if (orders == null || orders.isEmpty) {
            return _emptyState('No available orders', Icons.inbox_outlined);
          }
          return ListView.builder(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 80.h),
            itemCount: orders.length + (state.isOffline ? 1 : 0),
            itemBuilder: (_, i) {
              if (state.isOffline && i == 0) {
                return _offlineBanner();
              }
              final idx = state.isOffline ? i - 1 : i;
              return OrdersCard(order: orders[idx], index: idx);
            },
          );
        }
        return const Center(child: CustomErrorWidget(errMessage: 'Try Again Later'));
      },
    );
  }

  Widget _buildAcceptedOrders(BuildContext context) {
    return BlocBuilder<GetAcceptedOrderCubit, GetAcceptedOrderState>(
      builder: (context, state) {
        if (state is GetAcceptedOrderLoading) {
          return ShimmerLoading.orderHistory();
        } else if (state is GetAcceptedOrderFailure) {
          return Center(child: CustomErrorWidget(errMessage: state.errMessage));
        } else if (state is GetAcceptedOrderSuccess) {
          final orders = state.getAcceptedOrder.data?.order
              ?.where((o) => o.status?.toLowerCase() == "accepted" || o.status?.toLowerCase() == "picked_up" || o.status?.toLowerCase() == "shipped")
              .toList();
          if (orders == null || orders.isEmpty) {
            return _emptyState('No accepted orders', Icons.check_circle_outline);
          }
          return ListView.builder(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 80.h),
            itemCount: orders.length,
            itemBuilder: (_, i) => AcceptedCard(order: orders[i]),
          );
        }
        return const Center(child: Text('Something went wrong'));
      },
    );
  }

  Widget _buildCompletedOrders(BuildContext context) {
    return BlocBuilder<GetAcceptedOrderCubit, GetAcceptedOrderState>(
      builder: (context, state) {
        if (state is GetAcceptedOrderLoading) {
          return ShimmerLoading.orderHistory();
        } else if (state is GetAcceptedOrderFailure) {
          return Center(child: CustomErrorWidget(errMessage: state.errMessage));
        } else if (state is GetAcceptedOrderSuccess) {
          final orders = state.getAcceptedOrder.data?.order
              ?.where((o) => o.status?.toLowerCase() == "delivered")
              .toList();
          if (orders == null || orders.isEmpty) {
            return _emptyState('No completed orders yet', Icons.checklist);
          }
          return ListView.builder(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 80.h),
            itemCount: orders.length,
            itemBuilder: (_, i) => AcceptedCard(order: orders[i]),
          );
        }
        return const Center(child: Text('Something went wrong'));
      },
    );
  }

  Widget _emptyState(String message, IconData icon) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: 300.h,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 56, color: const Color(0xFFD1D5DB)),
              SizedBox(height: 16.h),
              Text(message,
                  style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF9CA3AF))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _offlineBanner() {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFFCD34D)),
      ),
      child: Row(
        children: [
          const Icon(Icons.wifi_off, size: 16, color: Color(0xFFD97706)),
          SizedBox(width: 8.w),
          Text("Offline — showing cached orders",
              style: appStyle(13, FontWeight.w500, const Color(0xFF92400E))),
        ],
      ),
    );
  }
}