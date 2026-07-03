import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ship_link/constant/colors.dart';
import 'package:ship_link/localization.dart';
import 'package:ship_link/cubitDriver/acceptOrder/accept_order_cubit.dart';
import 'package:ship_link/cubitDriver/getAcceptedOrders/get_accepted_order_cubit.dart';
import 'package:ship_link/cubitDriver/get_orders/get_orders_cubit.dart';
import 'package:ship_link/views/driver/screens/ordersScreen/components/order_route_screen.dart';
import 'package:ship_link/views/shared/app_style.dart';
import 'package:ship_link/views/shared/snackBar/snack_bar.dart';
import 'package:ship_link/utils/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

class OrdersCard extends StatefulWidget {
  final dynamic order;
  final int index;
  const OrdersCard({super.key, required this.order, required this.index});

  @override
  State<OrdersCard> createState() => _OrdersCardState();
}

class _OrdersCardState extends State<OrdersCard> {
  dynamic get order => widget.order;
  bool _isLoading = false;

  Future<void> _accept() async {
    setState(() => _isLoading = true);
    final cubit = context.read<AcceptOrderCubit>();
    await cubit.acceptOrders(orderId: order.id);
    if (!mounted) return;
    final state = cubit.state;
    if (state is AcceptOrderSuccess) {
      context.read<GetOrdersCubit>().getOrder();
      context.read<GetAcceptedOrderCubit>().getAcceptedOrder();
      CustomSnackBar.displaySuccessMotionToast(
          state.acceptOrder.message ?? context.t.tr('order_has_been_accepted'), context);
    } else if (state is AcceptOrderFailure) {
      if (state.errMessage == 'Selected order has been accepted') {
        context.read<GetOrdersCubit>().getOrder();
        context.read<GetAcceptedOrderCubit>().getAcceptedOrder();
        CustomSnackBar.displaySuccessMotionToast(
            context.t.tr('order_has_been_accepted'), context);
      } else {
        CustomSnackBar.displayErrorMotionToast(state.errMessage, context);
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: const [
          BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44.w, height: 44.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: const Icon(Icons.store, color: Color(0xFF6B7280), size: 24),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${context.t.tr('order_no')}${order.id ?? ''}',
                        style: appStyle(15, FontWeight.w600, const Color(0xFF111827)),
                        ),
                    SizedBox(height: 2.h),
                    Text(order.user?.firstName ?? context.t.tr('customer'),
                        style: appStyle(13, FontWeight.w400, const Color(0xFF6B7280)),
                        ),
                  ],
                ),
              ),
              _statusBadge(order.status ?? context.t.tr('pending')),
              const SizedBox(width: 6),
              _paymentBadge(order.paymentMethod ?? ''),
            ],
          ),
          SizedBox(height: 12.h),
          const Divider(height: 1),
          SizedBox(height: 12.h),
          Row(
            children: [
              const Icon(Icons.person_outline, size: 16, color: Color(0xFF6B7280)),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  '${order.user?.firstName ?? ''} ${order.user?.lastName ?? ''}',
                  style: appStyle(13, FontWeight.w500, const Color(0xFF111827)),
                ),
              ),
              Flexible(
                child: GestureDetector(
                  onTap: () async {
                    final phone = order.user?.phoneNumber ?? '';
                    if (phone.isNotEmpty) {
                      await launchUrl(Uri.parse('tel:$phone'));
                    }
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.phone_outlined, size: 16, color: Color(0xFF6B7280)),
                      SizedBox(width: 6.w),
                      Flexible(
                        child: Text(order.user?.phoneNumber ?? '',
                            style: appStyle(13, FontWeight.w400, const Color(0xFF6B7280)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _buildAddressRow(order),
          if (order.deliveryLat != null && order.deliveryLng != null) ...[
            SizedBox(height: 8.h),
            SizedBox(
              width: double.infinity,
              height: 38.h,
              child: OutlinedButton.icon(
                onPressed: () => _openRoutePreview(order),
                icon: const Icon(Icons.map, size: 16),
                label: Text(context.t.tr('show_route'),
                    style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2563EB),
                  side: const BorderSide(color: Color(0xFF2563EB)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                ),
              ),
            ),
          ],
          SizedBox(height: 12.h),
          Row(
            children: [
              Text('${context.t.tr('total_colon')}',
                  style: appStyle(14, FontWeight.w500, const Color(0xFF6B7280))),
              SizedBox(width: 4.w),
              Text('${context.t.tr('egp')} ${order.totalPrice ?? '0'}',
                  style: appStyle(18, FontWeight.w700, const Color(0xFF10B981))),
              const Spacer(),
            ],
          ),
          SizedBox(height: 14.h),
          SizedBox(
            width: double.infinity,
            height: 44.h,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _accept,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r)),
              ),
              child: _isLoading
                  ? SizedBox(
                      width: 20.w, height: 20.h,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : Text(context.t.tr('accept_order'),
                      style: TextStyle(
                          fontSize: 15.sp, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressRow(dynamic order) {
    final address = order.deliveryAddress ?? '';
    final label = order.addressLabel ?? '';
    final lat = order.deliveryLat;
    final lng = order.deliveryLng;
    if (address.isEmpty && lat == null) return const SizedBox.shrink();
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24.w, height: 24.h,
            decoration: BoxDecoration(
              color: lat != null && lng != null
                  ? const Color(0xFF2563EB).withValues(alpha: 0.1)
                  : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Icon(
              lat != null && lng != null ? Icons.map : Icons.location_on_outlined,
              size: 14, color: lat != null && lng != null
                  ? const Color(0xFF2563EB)
                  : const Color(0xFF6B7280),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (label.isNotEmpty)
                  Text(label,
                      style: appStyle(12, FontWeight.w600, const Color(0xFF111827))),
                if (address.isNotEmpty)
                  Text(address,
                      style: appStyle(12, FontWeight.w400, const Color(0xFF6B7280)),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                if (lat != null && lng != null) ...[
                  SizedBox(height: 4.h),
                  _DistanceLabel(destLat: lat.toDouble(), destLng: lng.toDouble()),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openRoutePreview(dynamic order) async {
    final lat = order.deliveryLat;
    final lng = order.deliveryLng;
    if (lat == null || lng == null) return;
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrderRouteScreen(
          destLat: lat.toDouble(),
          destLng: lng.toDouble(),
          addressLabel: order.addressLabel,
          address: order.deliveryAddress,
          orderId: '${order.id ?? ''}',
          userId: order.userId ?? '',
        ),
      ),
    );
  }

  Widget _paymentBadge(String method) {
    if (method == 'card') {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: const Color(0xFFD1FAE5),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, size: 14, color: Color(0xFF059669)),
            SizedBox(width: 4.w),
            Text(context.t.tr('paid'), style: appStyle(12, FontWeight.w600, const Color(0xFF059669))),
          ],
        ),
      );
    }
    if (method == 'cod') {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF3C7),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Text(context.t.tr('cod'), style: appStyle(12, FontWeight.w600, const Color(0xFFD97706))),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _statusBadge(String status) {
    Color bg;
    Color fg;
    switch (status.toLowerCase()) {
      case 'accepted':
        bg = const Color(0xFFDBEAFE);
        fg = const Color(0xFF2563EB);
        break;
      case 'delivered':
        bg = const Color(0xFFD1FAE5);
        fg = const Color(0xFF059669);
        break;
      default:
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFD97706);
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8.r)),
      child: Text(status, style: appStyle(12, FontWeight.w600, fg)),
    );
  }
}

class AcceptedCard extends StatefulWidget {
  final dynamic order;
  const AcceptedCard({super.key, required this.order});

  @override
  State<AcceptedCard> createState() => _AcceptedCardState();
}

class _AcceptedCardState extends State<AcceptedCard> {
  dynamic get order => widget.order;
  bool _loadingPickedUp = false;
  bool _loadingShipped = false;
  bool _loadingDelivered = false;
  bool _loadingCancel = false;

  void _refreshAll() {
    if (!mounted) return;
    context.read<GetOrdersCubit>().getOrder();
    context.read<GetAcceptedOrderCubit>().getAcceptedOrder();
  }

  Future<void> _markPickedUp() async {
    setState(() => _loadingPickedUp = true);
    await context.read<AcceptOrderCubit>().markPickedUp(orderId: order.id);
    _refreshAll();
    if (mounted) setState(() => _loadingPickedUp = false);
  }

  Future<void> _markShipped() async {
    setState(() => _loadingShipped = true);
    await context.read<AcceptOrderCubit>().markShipped(orderId: order.id);
    _refreshAll();
    if (mounted) setState(() => _loadingShipped = false);
  }

  Future<void> _markDelivered() async {
    setState(() => _loadingDelivered = true);
    await context.read<AcceptOrderCubit>().markDelivered(orderId: order.id);
    _refreshAll();
    if (mounted) setState(() => _loadingDelivered = false);
  }

  Future<void> _cancel() async {
    setState(() => _loadingCancel = true);
    await context.read<AcceptOrderCubit>().cancelOrder(orderId: order.id);
    _refreshAll();
    if (mounted) setState(() => _loadingCancel = false);
  }

  Widget _buildAcceptedAddressRow(dynamic order) {
    final address = order.deliveryAddress ?? '';
    final label = order.addressLabel ?? '';
    final lat = order.deliveryLat;
    final lng = order.deliveryLng;
    if (address.isEmpty && lat == null) return const SizedBox.shrink();
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24.w, height: 24.h,
            decoration: BoxDecoration(
              color: lat != null && lng != null
                  ? const Color(0xFF2563EB).withValues(alpha: 0.1)
                  : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Icon(
              lat != null && lng != null ? Icons.map : Icons.location_on_outlined,
              size: 14, color: lat != null && lng != null
                  ? const Color(0xFF2563EB)
                  : const Color(0xFF6B7280),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (label.isNotEmpty)
                  Text(label,
                      style: appStyle(12, FontWeight.w600, const Color(0xFF111827))),
                if (address.isNotEmpty)
                  Text(address,
                      style: appStyle(12, FontWeight.w400, const Color(0xFF6B7280)),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                if (lat != null && lng != null) ...[
                  SizedBox(height: 4.h),
                  _DistanceLabel(destLat: lat.toDouble(), destLng: lng.toDouble()),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openAcceptedRoutePreview(dynamic order) async {
    final lat = order.deliveryLat;
    final lng = order.deliveryLng;
    if (lat == null || lng == null) return;
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrderRouteScreen(
          destLat: lat.toDouble(),
          destLng: lng.toDouble(),
          addressLabel: order.addressLabel,
          address: order.deliveryAddress,
          orderId: '${order.id ?? ''}',
          userId: order.userId ?? '',
        ),
      ),
    );
  }

  Color _statusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'accepted':   return const Color(0xFF2563EB);
      case 'shipped':    return const Color(0xFFD97706);
      case 'delivered':  return const Color(0xFF059669);
      case 'cancelled':  return const Color(0xFFDC2626);
      default:           return const Color(0xFF6B7280);
    }
  }

  Color _statusBg(String? status) {
    switch (status?.toLowerCase()) {
      case 'accepted':   return const Color(0xFFDBEAFE);
      case 'shipped':    return const Color(0xFFFEF3C7);
      case 'delivered':  return const Color(0xFFD1FAE5);
      case 'cancelled':  return const Color(0xFFFEE2E2);
      default:           return const Color(0xFFF3F4F6);
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = order.status?.toString() ?? '';
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: const [
          BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44.w, height: 44.h,
                decoration: BoxDecoration(
                  color: _statusBg(status),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  status.toLowerCase() == 'delivered' ? Icons.check_circle :
                  status.toLowerCase() == 'cancelled' ? Icons.cancel :
                  Icons.local_shipping,
                  color: _statusColor(status), size: 24),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${context.t.tr('order_no')}${order.id ?? ''}',
                        style: appStyle(15, FontWeight.w600, const Color(0xFF111827)),
                        ),
                    SizedBox(height: 2.h),
                    Text(order.user?.firstName ?? context.t.tr('customer'),
                        style: appStyle(13, FontWeight.w400, const Color(0xFF6B7280)),
                        ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: _statusBg(status),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(status,
                    style: appStyle(12, FontWeight.w600, _statusColor(status))),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          const Divider(height: 1),
          SizedBox(height: 12.h),
          Row(
            children: [
              const Icon(Icons.person_outline, size: 16, color: Color(0xFF6B7280)),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  '${order.user?.firstName ?? ''} ${order.user?.lastName ?? ''}',
                  style: appStyle(13, FontWeight.w500, const Color(0xFF111827)),
                ),
              ),
              Flexible(
                child: GestureDetector(
                  onTap: () async {
                    final phone = order.user?.phoneNumber ?? '';
                    if (phone.isNotEmpty) {
                      await launchUrl(Uri.parse('tel:$phone'));
                    }
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.phone_outlined, size: 16, color: Color(0xFF6B7280)),
                      SizedBox(width: 6.w),
                      Flexible(
                        child: Text(order.user?.phoneNumber ?? '',
                            style: appStyle(13, FontWeight.w400, const Color(0xFF6B7280)),
                        ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          ),
          SizedBox(height: 12.h),
          _buildAcceptedAddressRow(order),
          if (order.deliveryLat != null && order.deliveryLng != null) ...[
            SizedBox(height: 8.h),
            SizedBox(
              width: double.infinity,
              height: 38.h,
              child: OutlinedButton.icon(
                onPressed: () => _openAcceptedRoutePreview(order),
                icon: const Icon(Icons.map, size: 16),
                label: Text(context.t.tr('show_route'),
                    style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2563EB),
                  side: const BorderSide(color: Color(0xFF2563EB)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                ),
              ),
            ),
          ],
          SizedBox(height: 12.h),
          Row(
            children: [
              Text('${context.t.tr('total_colon')}',
                  style: appStyle(14, FontWeight.w500, const Color(0xFF6B7280))),
              SizedBox(width: 4.w),
              Text('${context.t.tr('egp')} ${order.totalPrice ?? '0'}',
                  style: appStyle(18, FontWeight.w700, const Color(0xFF10B981))),
            ],
          ),
          if (status.toLowerCase() == 'accepted') ...[
            SizedBox(height: 14.h),
            const Divider(height: 1),
            SizedBox(height: 14.h),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40.h,
                    child: ElevatedButton.icon(
                      onPressed: _loadingPickedUp ? null : _markPickedUp,
                      icon: _loadingPickedUp
                          ? SizedBox(width: 18.w, height: 18.h, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.check_circle_outline, size: 18),
                      label: Text(context.t.tr('mark_picked_up')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: SizedBox(
                    height: 40.h,
                    child: OutlinedButton.icon(
                      onPressed: _loadingCancel ? null : _cancel,
                      icon: _loadingCancel
                          ? SizedBox(width: 18.w, height: 18.h, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.cancel_outlined, size: 18),
                      label: Text(context.t.tr('cancel')),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFDC2626),
                        side: const BorderSide(color: Color(0xFFDC2626)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (status.toLowerCase() == 'picked_up') ...[
            SizedBox(height: 14.h),
            const Divider(height: 1),
            SizedBox(height: 14.h),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40.h,
                    child: ElevatedButton.icon(
                      onPressed: _loadingShipped ? null : _markShipped,
                      icon: _loadingShipped
                          ? SizedBox(width: 18.w, height: 18.h, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.local_shipping, size: 18),
                      label: Text(context.t.tr('mark_shipped')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD97706),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: SizedBox(
                    height: 40.h,
                    child: OutlinedButton.icon(
                      onPressed: _loadingCancel ? null : _cancel,
                      icon: _loadingCancel
                          ? SizedBox(width: 18.w, height: 18.h, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.cancel_outlined, size: 18),
                      label: Text(context.t.tr('cancel')),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFDC2626),
                        side: const BorderSide(color: Color(0xFFDC2626)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (status.toLowerCase() == 'shipped') ...[
            SizedBox(height: 14.h),
            const Divider(height: 1),
            SizedBox(height: 14.h),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40.h,
                    child: ElevatedButton.icon(
                      onPressed: _loadingDelivered ? null : _markDelivered,
                      icon: _loadingDelivered
                          ? SizedBox(width: 18.w, height: 18.h, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.check_circle, size: 18),
                      label: Text(context.t.tr('mark_delivered')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF059669),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: SizedBox(
                    height: 40.h,
                    child: OutlinedButton.icon(
                      onPressed: _loadingCancel ? null : _cancel,
                      icon: _loadingCancel
                          ? SizedBox(width: 18.w, height: 18.h, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.cancel_outlined, size: 18),
                      label: Text(context.t.tr('cancel')),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFDC2626),
                        side: const BorderSide(color: Color(0xFFDC2626)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _DistanceLabel extends StatefulWidget {
  final double destLat;
  final double destLng;
  const _DistanceLabel({required this.destLat, required this.destLng});

  @override
  State<_DistanceLabel> createState() => _DistanceLabelState();
}

class _DistanceLabelState extends State<_DistanceLabel> {
  String? _distance;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _compute();
  }

  Future<void> _compute() async {
    try {
      final pos = await Geolocator.getLastKnownPosition();
      if (pos != null) {
        final dist = Geolocator.distanceBetween(
              pos.latitude, pos.longitude, widget.destLat, widget.destLng,
            ) / 1000;
        if (mounted) {
          setState(() {
            _distance = '${dist.toStringAsFixed(1)} ${context.t.tr('km')}';
            _loading = false;
          });
        }
        return;
      }
      final pos2 = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 4),
        ),
      );
      final dist = Geolocator.distanceBetween(
            pos2.latitude, pos2.longitude, widget.destLat, widget.destLng,
          ) / 1000;
      if (mounted) {
        setState(() {
          _distance = '${dist.toStringAsFixed(1)} ${context.t.tr('km')}';
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return SizedBox(width: 40.w, height: 12.h, child: LinearProgressIndicator());
    }
    if (_distance == null) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.directions_car, size: 12, color: Color(0xFF6B7280)),
        SizedBox(width: 3.w),
            Text('$_distance ${context.t.tr('away')}',
            style: appStyle(11, FontWeight.w500, const Color(0xFF6B7280))),
      ],
    );
  }
}