import 'package:flutter/material.dart';
import 'package:ship_link/utils/sizer.dart';
import 'package:ship_link/constant/colors.dart';
import 'package:ship_link/localization.dart';
import 'package:ship_link/views/shared/snackBar/snack_bar.dart';
import 'package:ship_link/views/shared/app_style.dart';
import 'package:ship_link/views/shared/shimmer/shimmer_loading.dart';
import 'package:ship_link/views/user/screens/tracking/driver_tracking_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Delivered extends StatefulWidget {
  Delivered({super.key, String? statusFilter}) : statusFilter = statusFilter;
  static String routName = '/delivered';
  final String? statusFilter;

  @override
  State<Delivered> createState() => _DeliveredState();
}

class _DeliveredState extends State<Delivered> {
  Future<List<Map<String, dynamic>>>? _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = _loadOrders();
  }

  Future<List<Map<String, dynamic>>> _loadOrders() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return [];

    var query = Supabase.instance.client
        .from('orders')
        .select('*')
        .eq('user_id', userId);

    if (widget.statusFilter != null) {
      query = query.eq('status', widget.statusFilter!);
    }

    return await query.order('created_at', ascending: false).limit(50);
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppColors.warning;
      case 'shipped':
      case 'confirmed':
        return AppColors.primary;
      case 'in_transit':
        return AppColors.info;
      case 'delivered':
        return AppColors.success;
      case 'cancelled':
      case 'canceled':
        return AppColors.error;
      default:
        return AppColors.textHint;
    }
  }

  Future<void> _orderAgain(BuildContext context, dynamic orderId) async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return;
    try {
      final items = await Supabase.instance.client
          .from('order_items')
          .select('product_id, quantity')
          .eq('order_id', orderId);
      if (!mounted) return;
      if (items.isEmpty) {
        CustomSnackBar.info('No items found for this order', context);
        return;
      }
      for (final item in items) {
        final existing = await Supabase.instance.client
            .from('cart_items')
            .select('id, quantity')
            .eq('user_id', uid)
            .eq('product_id', item['product_id'] as int)
            .maybeSingle();
        if (existing != null) {
          await Supabase.instance.client
              .from('cart_items')
              .update({'quantity': (existing['quantity'] as int? ?? 0) + (item['quantity'] as int? ?? 1)})
              .eq('id', existing['id'] as int);
        } else {
          int? cartId;
          final anyItem = await Supabase.instance.client
              .from('cart_items')
              .select('cart_id')
              .eq('user_id', uid)
              .limit(1)
              .maybeSingle();
          if (anyItem != null) cartId = anyItem['cart_id'] as int?;
          cartId ??= DateTime.now().millisecondsSinceEpoch;
          await Supabase.instance.client.from('cart_items').insert({
            'user_id': uid,
            'product_id': item['product_id'],
            'quantity': item['quantity'],
            'cart_id': cartId,
          });
        }
      }
      if (mounted) {
        CustomSnackBar.success(context.t.tr('items_added_to_cart'), context);
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.error('$e', context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _ordersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ShimmerLoading.orderHistory();
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 48.sp, color: AppColors.error),
                SizedBox(height: 12.h),
                Text('${snapshot.error}', style: appStyle(14, FontWeight.w500, AppColors.textSecondary), textAlign: TextAlign.center),
                SizedBox(height: 12.h),
                ElevatedButton.icon(
                  onPressed: () => setState(() => _ordersFuture = _loadOrders()),
                  icon: Icon(Icons.refresh, size: 18.sp),
                  label: Text(context.t.tr('retry')),
                ),
              ],
            ),
          );
        }
        final orders = snapshot.data ?? [];
        if (orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.receipt_long, size: 64.sp, color: AppColors.textHint),
                SizedBox(height: 16.h),
                Text(context.t.tr('no_orders_yet'), style: appStyle(16, FontWeight.w500, AppColors.textSecondary)),
                SizedBox(height: 8.h),
                Text(context.t.tr('no_orders_hint'), style: appStyle(13, FontWeight.w400, AppColors.textHint)),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            final id = order['id'] ?? 0;
            final total = order['total_price'] ?? 0;
            final status = order['status'] ?? 'pending';
            final createdAt = order['created_at'] ?? '';
            final date = createdAt is String && createdAt.length >= 10
                ? createdAt.substring(0, 10)
                : '';

            return Container(
              width: double.infinity,
              margin: EdgeInsets.only(bottom: 12.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                color: AppColors.surface,
              ),
              child: Padding(
                padding: EdgeInsets.all(14.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${context.t.tr('order_no')} #$id',
                          style: appStyle(15, FontWeight.w600, AppColors.textPrimary),
                        ),
                        Text(date, style: appStyle(12, FontWeight.w400, AppColors.textHint)),
                      ],
                    ),
                    Divider(height: 20.h, color: AppColors.border),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text.rich(TextSpan(children: [
                          TextSpan(
                            text: context.t.tr('total_amount'),
                            style: appStyle(14, FontWeight.w500, AppColors.textSecondary),
                          ),
                          TextSpan(
                            text: '\$$total',
                            style: appStyle(15, FontWeight.w700, AppColors.cta),
                          ),
                        ])),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: _statusColor(status.toString()).withAlpha(25),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            context.t.tr(status.toString()),
                            style: appStyle(12, FontWeight.w600, _statusColor(status.toString())),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (status.toString().toLowerCase() == 'delivered')
                          Padding(
                          padding: EdgeInsets.only(right: 8.w),
                          child: GestureDetector(
                            onTap: () => _orderAgain(context, id),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                              decoration: BoxDecoration(
                                color: AppColors.success,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.replay, size: 14.sp, color: Colors.white),
                                  SizedBox(width: 4.w),
                                    Text(
                                      context.t.tr('order_again'),
                                      style: appStyle(13, FontWeight.w500, Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        if (order['driver_id'] != null && !['delivered', 'cancelled'].contains(status.toString().toLowerCase()))
                          Padding(
                            padding: EdgeInsets.only(right: 8.w),
                            child: GestureDetector(
                              onTap: () => Navigator.pushNamed(
                                context,
                                DriverTrackingScreen.routName,
                                arguments: id.toString(),
                              ),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                                decoration: BoxDecoration(
                                  color: AppColors.cta,
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.navigation, size: 14.sp, color: Colors.white),
                                    SizedBox(width: 4.w),
                                    Text(
                                      context.t.tr('track_shipment'),
                                      style: appStyle(13, FontWeight.w500, Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/orderDetail',
                            arguments: id,
                          ),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              context.t.tr('detail'),
                              style: appStyle(14, FontWeight.w500, Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}