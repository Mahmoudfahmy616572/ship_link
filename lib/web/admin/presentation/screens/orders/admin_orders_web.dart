import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/core/utils/sizer.dart';
import 'package:ship_link/web/admin/presentation/cubits/orders/admin_orders_cubit.dart';
import 'package:ship_link/web/admin/presentation/screens/shared/admin_stat_card.dart';
import 'package:ship_link/web/admin/presentation/screens/orders/widgets/orders_widgets.dart';
import 'package:ship_link/web/admin/presentation/screens/orders/admin_order_detail_web.dart';

// شاشة قائمة الطلبات
class AdminOrdersWeb extends StatefulWidget {
  final void Function(int orderId)? onOpenDetail;
  const AdminOrdersWeb({super.key, this.onOpenDetail});

  @override
  State<AdminOrdersWeb> createState() => _AdminOrdersWebState();
}

class _AdminOrdersWebState extends State<AdminOrdersWeb> {
  // بنحتفظ بالـ orders في متغير عشان لما نرجع من تفاصيل الأوردر
  // منضطرش نعتمد على الـ state اللي ممكن يكون لسه AdminOrderDetailLoaded
  List<Map<String, dynamic>> _orders = [];

  @override
  void initState() {
    super.initState();
    // نتأكد إن الأوردرز متحملين أول ما الشاشة تفتح
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<AdminOrdersCubit>().state is! AdminOrdersLoaded) {
        context.read<AdminOrdersCubit>().loadOrders();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // لو رجعنا من شاشة تفاصيل الأوردر (الـ state لسه AdminOrderDetailLoaded)
    // نعيد تحميل القائمة عشان نرجع لـ AdminOrdersLoaded
    final st = context.read<AdminOrdersCubit>().state;
    if (st is AdminOrderDetailLoaded && _orders.isEmpty) {
      context.read<AdminOrdersCubit>().loadOrders();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AdminOrdersCubit, dynamic>(
      listener: (context, state) {
        if (state is AdminOrdersLoaded) {
          setState(() => _orders = state.orders);
        }
      },
      child: BlocBuilder<AdminOrdersCubit, dynamic>(
        builder: (context, state) {
          if (state is AdminOrdersInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AdminOrdersLoading && _orders.isEmpty) {
            return const OrdersTableShimmer();
          }
          if (state is AdminOrdersError && _orders.isEmpty) {
            return OrdersErrorView(state.message, () => context.read<AdminOrdersCubit>().loadOrders());
          }
          final orders = _orders;

          return SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AdminSectionTitle('Orders'),
                SizedBox(height: 16.h),
                OrdersTable(
                  orders,
                  onOpenDetail: (o) => widget.onOpenDetail?.call(o['id'] as int),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
