import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/driver/presentation/cubits/acceptOrder/accept_order_cubit.dart';
import 'package:ship_link/driver/presentation/cubits/getAcceptedOrders/get_accepted_order_cubit.dart';
import 'package:ship_link/driver/presentation/cubits/get_orders/get_orders_cubit.dart';
import 'package:ship_link/driver/presentation/screens/ordersScreen/components/order_route_screen.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/widgets/app_style.dart';
import 'package:ship_link/core/widgets/snackBar/snack_bar.dart';
import 'package:ship_link/core/widgets/adaptive_map.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ship_link/core/utils/sizer.dart';

class OrdersMapScreen extends StatefulWidget {
  const OrdersMapScreen({super.key});
  static String routName = '/OrdersMap';

  @override
  State<OrdersMapScreen> createState() => _OrdersMapScreenState();
}

class _OrdersMapScreenState extends State<OrdersMapScreen> {
  final _vm = ValueNotifier<_OrdersMapVm>(const _OrdersMapVm(
    orders: [],
    loading: true,
    driverLat: null,
    driverLng: null,
    locationReady: false,
  ));

  @override
  void initState() {
    super.initState();
    _fetchOrders();
    _initLocation();
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  Future<void> _initLocation() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 8),
        ),
      );
      if (mounted) {
        _vm.value = _OrdersMapVm(
          orders: _vm.value.orders,
          loading: _vm.value.loading,
          driverLat: pos.latitude,
          driverLng: pos.longitude,
          locationReady: true,
        );
      }
    } catch (_) {
      if (mounted) {
        _vm.value = _OrdersMapVm(
          orders: _vm.value.orders,
          loading: _vm.value.loading,
          driverLat: _vm.value.driverLat,
          driverLng: _vm.value.driverLng,
          locationReady: true,
        );
      }
    }
  }

  Future<void> _fetchOrders() async {
    try {
      final data = await Supabase.instance.client
          .from('orders')
          .select('*, profiles!inner(*)')
          .neq('status', 'accepted')
          .neq('status', 'shipped')
          .neq('status', 'delivered')
          .neq('status', 'cancelled');
      if (mounted) {
        _vm.value = _OrdersMapVm(
          orders: data,
          loading: false,
          driverLat: _vm.value.driverLat,
          driverLng: _vm.value.driverLng,
          locationReady: _vm.value.locationReady,
        );
      }
    } catch (_) {
      if (mounted) {
        _vm.value = _OrdersMapVm(
          orders: _vm.value.orders,
          loading: false,
          driverLat: _vm.value.driverLat,
          driverLng: _vm.value.driverLng,
          locationReady: _vm.value.locationReady,
        );
      }
    }
  }

  List<MapMarker> _buildMarkers(_OrdersMapVm vm) {
    final markers = <MapMarker>[];

    if (vm.driverLat != null && vm.driverLng != null) {
      markers.add(MapMarker(
        id: 'driver',
        latitude: vm.driverLat!,
        longitude: vm.driverLng!,
        icon: buildDriverMarker(),
        label: context.t.tr('you'),
      ));
    }

    for (final o in vm.orders) {
      double? lat = (o['delivery_lat'] as num?)?.toDouble();
      double? lng = (o['delivery_lng'] as num?)?.toDouble();
      if (lat == null || lng == null) {
        final profile = o['profiles'] as Map<String, dynamic>?;
        lat = (profile?['latitude'] as num?)?.toDouble();
        lng = (profile?['longitude'] as num?)?.toDouble();
      }
      if (lat == null || lng == null) continue;
      markers.add(MapMarker(
        id: 'order_${o['id']}',
        latitude: lat,
        longitude: lng,
        icon: const Icon(Icons.location_on, color: Color(0xFF2563EB), size: 36),
      ));
    }

    return markers;
  }

  void _onMarkerTapped(MapMarker marker) {
    if (marker.id == 'driver') return;
    final orderId = marker.id.replaceFirst('order_', '');
    final order = _vm.value.orders.firstWhere(
      (o) => o['id'].toString() == orderId,
      orElse: () => <String, dynamic>{},
    );
    if (order.isEmpty) return;
    _showOrderSheet(order);
  }

  void _showOrderSheet(Map<String, dynamic> order) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) {
        final profile = order['profiles'] as Map<String, dynamic>?;
        final name = order['customer_name'] as String? ?? profile?['name'] ?? context.t.tr('customer');
        final profilePhone = profile?['phone_number'] as String? ?? '';
        final orderPhone = order['phone_number'] as String? ?? '';
        final phone = orderPhone.isNotEmpty ? orderPhone : profilePhone;
        final total = order['total_price'] ?? '0';
        return Padding(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36.w, height: 4.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1D5DB),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Text('${context.t.tr('order_no')}${order['id']}',
                  style: appStyle(18, FontWeight.w600, const Color(0xFF111827))),
              SizedBox(height: 12.h),
              _infoRow(Icons.person_outline, name),
              if (phone.isNotEmpty) ...[
                SizedBox(height: 6.h),
                _infoRow(Icons.phone_outlined, phone),
              ],
              SizedBox(height: 6.h),
              _infoRow(Icons.receipt_outlined, '${context.t.tr('egp')} $total'),
              if (order['address_label'] != null) ...[
                SizedBox(height: 6.h),
                _infoRow(Icons.label_outline, order['address_label']),
              ],
              if (order['delivery_address'] != null || order['delivery_lat'] != null) ...[
                SizedBox(height: 6.h),
                _tappableAddressRow(order),
              ],
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                height: 44.h,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _acceptOrder(order['id']);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r)),
                  ),
                  child: Text(context.t.tr('accept_order'),
                      style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF6B7280)),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(text,
              style: appStyle(14, FontWeight.w400, const Color(0xFF111827))),
        ),
      ],
    );
  }

  Widget _tappableAddressRow(Map<String, dynamic> order) {
    final address = order['delivery_address'] as String? ?? '';
    final label = order['address_label'] as String? ?? '';
    final lat = (order['delivery_lat'] as num?)?.toDouble();
    final lng = (order['delivery_lng'] as num?)?.toDouble();
    final hasLocation = lat != null && lng != null;
    return GestureDetector(
      onTap: hasLocation
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OrderRouteScreen(
                    destLat: lat,
                    destLng: lng,
                    addressLabel: label.isNotEmpty ? label : null,
                    address: address.isNotEmpty ? address : null,
                    orderId: '${order['id'] ?? ''}',
                    userId: order['user_id']?.toString() ?? '',
                  ),
                ),
              );
            }
          : null,
      child: Row(
        children: [
          Container(
            width: 28.w, height: 28.h,
            decoration: BoxDecoration(
              color: hasLocation
                  ? const Color(0xFF2563EB).withValues(alpha: 0.1)
                  : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(7.r),
            ),
            child: Icon(
              hasLocation ? Icons.map : Icons.location_on_outlined,
              size: 16,
              color: hasLocation ? const Color(0xFF2563EB) : const Color(0xFF6B7280),
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
                      style: appStyle(13, FontWeight.w400, const Color(0xFF6B7280)),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                if (hasLocation)
                  Text('${context.t.tr('view_route')} →',
                      style: appStyle(12, FontWeight.w600, const Color(0xFF2563EB))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _acceptOrder(dynamic orderId) async {
    final cubit = context.read<AcceptOrderCubit>();
    await cubit.acceptOrders(orderId: orderId is int ? orderId : int.tryParse(orderId.toString()) ?? 0);
    if (!mounted) return;
    final state = cubit.state;
    if (state is AcceptOrderSuccess) {
      context.read<GetOrdersCubit>().getOrder();
      context.read<GetAcceptedOrderCubit>().getAcceptedOrder();
      CustomSnackBar.displaySuccessMotionToast(context.t.tr('order_accepted'), context);
    } else if (state is AcceptOrderFailure) {
      CustomSnackBar.displayErrorMotionToast(state.errMessage, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<_OrdersMapVm>(
      valueListenable: _vm,
      builder: (context, vm, _) {
        final centerLat = vm.driverLat ?? 30.0444;
        final centerLng = vm.driverLng ?? 31.2357;

        return Scaffold(
          appBar: AppBar(
            title: Text(context.t.tr('orders_map')),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0.5,
          ),
          body: vm.loading
              ? const Center(child: CircularProgressIndicator())
              : vm.orders.isEmpty && !vm.locationReady
                  ? const Center(child: CircularProgressIndicator())
                  : AdaptiveMap(
                      initialLatitude: centerLat,
                      initialLongitude: centerLng,
                      initialZoom: vm.driverLat != null ? 13 : 10,
                      markers: _buildMarkers(vm),
                      onMarkerTapped: _onMarkerTapped,
                      showMyLocation: true,
                      showMyLocationButton: true,
                    ),
        );
      },
    );
  }
}

class _OrdersMapVm {
  final List<Map<String, dynamic>> orders;
  final bool loading;
  final double? driverLat;
  final double? driverLng;
  final bool locationReady;

  const _OrdersMapVm({
    required this.orders,
    required this.loading,
    this.driverLat,
    this.driverLng,
    required this.locationReady,
  });
}
