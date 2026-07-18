import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/widgets/app_style.dart';
import 'package:ship_link/core/utils/sizer.dart';
import 'package:ship_link/web/admin/presentation/cubits/orders/admin_orders_cubit.dart';
import 'package:ship_link/web/admin/presentation/screens/orders/widgets/orders_widgets.dart';
import 'package:ship_link/web/admin/presentation/screens/shared/admin_toast.dart';

// شاشة تفاصيل الطلب (المنتجات + تغيير الحالة)
class AdminOrderDetailWeb extends StatelessWidget {
  final int orderId;
  final VoidCallback? onBack;
  final void Function(int orderId)? onOpenDetail;
  const AdminOrderDetailWeb({super.key, required this.orderId, this.onBack, this.onOpenDetail});

  static const _statuses = ['pending', 'confirmed', 'shipped', 'delivered', 'cancelled'];

  @override
  Widget build(BuildContext context) {
    // لما الشاشة تفتح، نتأكد إن تفاصيل الطلب ده متحملين
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<AdminOrdersCubit>().state is! AdminOrderDetailLoaded) {
        context.read<AdminOrdersCubit>().loadOrderItems(orderId);
      }
    });

    final t = context.t;
    return BlocBuilder<AdminOrdersCubit, dynamic>(
      builder: (context, state) {
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
                    onPressed: () => onBack?.call(),
                  ),
                  SizedBox(width: 8.w),
                  Text('${t.tr('order_details')} #$orderId', style: appStyle(20, FontWeight.w700, AppColors.textPrimary)),
                ],
              ),
              SizedBox(height: 20.h),
              // بيانات الأوردر الأساسية (رقم، عميل، مجموع، حالة)
              if (state is AdminOrderDetailLoaded && state.order != null)
                OrderHeader(order: state.order!),
              if (state is AdminOrderDetailLoaded && state.order != null)
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
                    onPressed: () async {
                      if (s == 'cancelled') {
                        final confirmed = await AdminConfirmDialog.show(
                          context,
                          title: t.tr('cancel_order_title'),
                          message: t.tr('cancel_order_confirm'),
                          confirmColor: AppColors.error,
                        );
                        if (!confirmed) return;
                      }
                      context.read<AdminOrdersCubit>().updateStatus(id: orderId, status: s);
                      AdminToast.success(context, t.tr('status_updated'));
                    },
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
