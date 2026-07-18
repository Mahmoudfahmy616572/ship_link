import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/widgets/app_style.dart';
import 'package:ship_link/core/utils/sizer.dart';
import 'package:ship_link/web/admin/presentation/cubits/orders/admin_orders_cubit.dart';
import 'package:ship_link/web/admin/presentation/screens/shared/admin_stat_card.dart';
import 'package:ship_link/web/admin/presentation/screens/shared/admin_empty_state.dart';
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
  String? _activeStatus;
  String _search = '';

  // الـ status المتاحة للفلترة
  static const _statuses = ['pending', 'confirmed', 'shipped', 'delivered', 'cancelled'];

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
      context.read<AdminOrdersCubit>().loadOrders(status: _activeStatus, search: _search.isEmpty ? null : _search);
    }
  }

  void _filter(String? status) {
    setState(() => _activeStatus = status);
    context.read<AdminOrdersCubit>().loadOrders(status: status, search: _search.isEmpty ? null : _search);
  }

  void _onSearch(String v) {
    _search = v;
    context.read<AdminOrdersCubit>().loadOrders(status: _activeStatus, search: v.isEmpty ? null : v);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
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
            return OrdersErrorView(state.message, () => context.read<AdminOrdersCubit>().loadOrders(status: _activeStatus));
          }
          final orders = _orders;

          return SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AdminSectionTitle('Orders'),
                SizedBox(height: 16.h),
                // شريط البحث
                TextField(
                  onChanged: _onSearch,
                  decoration: InputDecoration(
                    hintText: t.tr('search_orders'),
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                  ),
                ),
                SizedBox(height: 16.h),
                // فلترة حسب الحالة (الـ chips قابلة للضغط)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _StatusFilterChip(
                      label: t.tr('all'),
                      selected: _activeStatus == null,
                      onTap: () => _filter(null),
                    ),
                    ..._statuses.map((s) => _StatusFilterChip(
                      label: s.toUpperCase(),
                      selected: _activeStatus == s,
                      color: OrderStatusChip.colorFor(s),
                      onTap: () => _filter(s),
                    )),
                  ],
                ),
                SizedBox(height: 16.h),
                if (orders.isEmpty)
                  AdminEmptyState(
                    icon: Icons.receipt_long_outlined,
                    message: t.tr('no_orders'),
                    onRetry: () => context.read<AdminOrdersCubit>().loadOrders(status: _activeStatus, search: _search.isEmpty ? null : _search),
                  )
                else
                  OrdersTable(
                    orders,
                    isCompact: MediaQuery.of(context).size.width <= 900,
                    onOpenDetail: (o) {
                      final id = o['id'];
                      final intId = id is int ? id : (id is String ? int.tryParse(id) : null);
                      if (intId != null) widget.onOpenDetail?.call(intId);
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// شيب فلترة الحالة
class _StatusFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color? color;
  final VoidCallback onTap;
  const _StatusFilterChip({required this.label, required this.selected, this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? AppColors.primary;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? activeColor.withValues(alpha: 0.12) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? activeColor : AppColors.border),
        ),
        child: Text(
          label,
          style: appStyle(13, FontWeight.w600, selected ? activeColor : AppColors.textSecondary),
        ),
      ),
    );
  }
}
