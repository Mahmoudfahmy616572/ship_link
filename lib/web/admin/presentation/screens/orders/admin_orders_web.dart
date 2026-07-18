import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/core/utils/sizer.dart';
import 'package:ship_link/web/admin/presentation/cubits/orders/admin_orders_cubit.dart';
import 'package:ship_link/web/admin/presentation/screens/shared/admin_stat_card.dart';
import 'package:ship_link/web/admin/presentation/screens/orders/widgets/orders_widgets.dart';

// شاشة قائمة الطلبات
class AdminOrdersWeb extends StatelessWidget {
  const AdminOrdersWeb({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminOrdersCubit, dynamic>(
      builder: (context, state) {
        if (state is AdminOrdersInitial) {
          context.read<AdminOrdersCubit>().loadOrders();
          return const Center(child: CircularProgressIndicator());
        }
        if (state is AdminOrdersLoading) {
          return const OrdersTableShimmer();
        }
        if (state is AdminOrdersError) {
          return OrdersErrorView(state.message, () => context.read<AdminOrdersCubit>().loadOrders());
        }
        // لو جت حالة تفاصيل، هنعرض الشاشة في حالة التحميل أو العرض
        final orders = (state is AdminOrdersLoaded) ? state.orders : <Map<String, dynamic>>[];

        return SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AdminSectionTitle('Orders'),
              SizedBox(height: 16.h),
              OrdersTable(
                orders,
                onOpenDetail: (o) => context.read<AdminOrdersCubit>().loadOrderItems(o['id'] as int),
              ),
            ],
          ),
        );
      },
    );
  }
}
