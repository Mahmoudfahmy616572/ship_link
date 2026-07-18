import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/widgets/app_style.dart';
import 'package:ship_link/core/utils/sizer.dart';
import 'package:ship_link/web/admin/presentation/cubits/orders/admin_orders_cubit.dart';
import 'package:ship_link/web/admin/presentation/screens/orders/widgets/orders_widgets.dart';

// شاشة تفاصيل الطلب (المنتجات + تغيير الحالة)
class AdminOrderDetailWeb extends StatelessWidget {
  final int orderId;
  const AdminOrderDetailWeb({super.key, required this.orderId});

  static const _statuses = ['pending', 'confirmed', 'shipped', 'delivered', 'cancelled'];

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return BlocBuilder<AdminOrdersCubit, dynamic>(
      builder: (context, state) {
        if (state is AdminOrdersInitial || state is AdminOrdersError || (state is! AdminOrderDetailLoaded)) {
          // لو لسه ما اتحملش تفاصيل الطلب ده، نحمله
          if (state is AdminOrdersInitial || state is AdminOrdersError ||
              (state is AdminOrderDetailLoaded && state.orderId != orderId)) {
            context.read<AdminOrdersCubit>().loadOrderItems(orderId);
          }
        }
        if (state is AdminOrdersLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is AdminOrdersError) {
          return OrdersErrorView(state.message, () => context.read<AdminOrdersCubit>().loadOrderItems(orderId));
        }
        final items = (state is AdminOrderDetailLoaded && state.orderId == orderId)
            ? state.items
            : <Map<String, dynamic>>[];

        return SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.read<AdminOrdersCubit>().loadOrders(),
                  ),
                  SizedBox(width: 8.w),
                  Text('${t.tr('order_details')} #$orderId', style: appStyle(20, FontWeight.w700, AppColors.textPrimary)),
                ],
              ),
              SizedBox(height: 20.h),
              // قائمة المنتجات
              OrderItemsList(items),
              SizedBox(height: 24.h),
              // تغيير الحالة
              Text(t.tr('order_status'), style: appStyle(16, FontWeight.w600, AppColors.textPrimary)),
              SizedBox(height: 12.h),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _statuses.map((s) {
                  final color = OrderStatusChip.colorFor(s);
                  return OutlinedButton(
                    onPressed: () => context.read<AdminOrdersCubit>().updateStatus(id: orderId, status: s),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: color,
                      side: BorderSide(color: color.withValues(alpha: 0.5)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(s.toUpperCase(), style: appStyle(13, FontWeight.w600, color)),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}
