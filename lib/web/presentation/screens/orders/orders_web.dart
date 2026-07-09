import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/widgets/app_style.dart';
import 'package:ship_link/web/presentation/screens/welcome/welcome_web.dart';
import 'package:ship_link/web/presentation/screens/chat/chat_list_web.dart';
import 'package:ship_link/web/presentation/screens/orders/order_detail_web.dart';
import 'package:ship_link/web/presentation/shared/shimmer.dart';
import 'package:ship_link/web/presentation/shared/hover_widget.dart';
import 'package:ship_link/core/utils/sizer.dart';
import 'package:ship_link/web/presentation/cubits/orderHistory/order_history_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

class OrdersWeb extends StatefulWidget {
  const OrdersWeb({super.key});
  static String routName = '/orders';

  @override
  State<OrdersWeb> createState() => _OrdersWebState();
}

class _OrdersWebState extends State<OrdersWeb> {
  @override
  void initState() {
    super.initState();
    context.read<OrderHistoryCubit>().loadOrders();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending': return const Color(0xFFF59E0B);
      case 'confirmed': return AppColors.primary;
      case 'shipped': return const Color(0xFF3B82F6);
      case 'delivered': return AppColors.success;
      case 'cancelled': return AppColors.error;
      default: return const Color(0xFF9CA3AF);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.receipt_long_outlined, size: 64, color: Color(0xFFD1D5DB)),
            SizedBox(height: 16.h),
            Text(context.t.tr('login_to_view_orders'),
                style: appStyle(16, FontWeight.w500, const Color(0xFF9CA3AF))),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, WelcomeWeb.routName),
              style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: Text(context.t.tr('sign_in')),
            ),
          ],
        ),
      );
    }

    final state = context.watch<OrderHistoryCubit>().state;
    final loading = state is OrderHistoryLoading;
    final orders = state is OrderHistoryLoaded ? state.orders : <Map<String, dynamic>>[];

    if (loading) {
      return ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: 3,
        itemBuilder: (_, __) => Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: ShimmerBox(height: 120, radius: 12),
        ),
      );
    }

    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.receipt_long_outlined, size: 64, color: Color(0xFFD1D5DB)),
            SizedBox(height: 16.h),
            Text(context.t.tr('no_orders_yet'),
                style: appStyle(16, FontWeight.w500, const Color(0xFF9CA3AF))),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.pushNamed(context, ChatListWeb.routName),
              icon: Icon(Icons.chat_outlined, size: 18),
              label: Text(context.t.tr('my_chats')),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                side: BorderSide(color: const Color(0xFFE5E7EB)),
                foregroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: orders.length,
      itemBuilder: (context, i) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: Duration(milliseconds: 300 + (i * 100)),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) => Opacity(opacity: value, child: Transform.translate(
          offset: Offset(0, 20 * (1 - value)), child: child,
        )),
        child: _OrderCard(order: orders[i], statusColor: _statusColor(orders[i]['status'] as String? ?? '')),
      ),
            ),
          ),
        ],
      );
  }
}

class _OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final Color statusColor;

  const _OrderCard({required this.order, required this.statusColor});

  @override
  Widget build(BuildContext context) {
    final id = order['id'] as int? ?? 0;
    final status = order['status'] as String? ?? '';
    final total = order['total_price'] as num? ?? 0;
    final date = order['created_at'] as String? ?? '';
    final currency = context.t.tr('egp');

    return HoverScale(
      onTap: () => Navigator.pushNamed(context, OrderDetailWeb.routName, arguments: id),
      child: Card(
        margin: EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('#$id', style: appStyle(16, FontWeight.w700, const Color(0xFF111827))),
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(status[0].toUpperCase() + status.substring(1),
                        style: appStyle(12, FontWeight.w600, statusColor)),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Text(currency, style: appStyle(14, FontWeight.w500, const Color(0xFF6B7280))),
                  SizedBox(width: 4),
                  Text(total.toStringAsFixed(0),
                      style: appStyle(22, FontWeight.w700, AppColors.cta)),
                ],
              ),
              SizedBox(height: 4),
              Text(date, style: appStyle(12, FontWeight.w400, const Color(0xFF9CA3AF))),
            ],
          ),
        ),
      ),
    );
  }
}
