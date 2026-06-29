import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ship_link/constant/colors.dart';
import 'package:ship_link/cubitDriver/acceptOrder/accept_order_cubit.dart';
import 'package:ship_link/cubitDriver/getAcceptedOrders/get_accepted_order_cubit.dart';
import 'package:ship_link/cubitDriver/get_orders/get_orders_cubit.dart';
import 'package:ship_link/views/driver/screens/ordersScreen/components/order_route_screen.dart';
import 'package:ship_link/views/shared/app_style.dart';
import 'package:ship_link/views/shared/snackBar/snack_bar.dart';
import 'package:ship_link/widgets/adaptive_map.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ship_link/utils/sizer.dart';

class OrdersMapScreen extends StatefulWidget {
  const OrdersMapScreen({super.key});
  static String routName = '/OrdersMap';

  @override
  State<OrdersMapScreen> createState() => _OrdersMapScreenState();
}

class _OrdersMapScreenState extends State<OrdersMapScreen> {
  List<Map<String, dynamic>> _orders = [];
  bool _loading = true;

  double? _driverLat;
  double? _driverLng;
  bool _locationReady = false;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
    _initLocation();
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
        setState(() {
          _driverLat = pos.latitude;
          _driverLng = pos.longitude;
          _locationReady = true;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _locationReady = true);
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
      if (mounted) setState(() => _orders = data);
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  List<MapMarker> _buildMarkers() {
    final markers = <MapMarker>[];

    if (_driverLat != null && _driverLng != null) {
      markers.add(MapMarker(
        id: 'driver',
        latitude: _driverLat!,
        longitude: _driverLng!,
        icon: buildDriverMarker(),
        label: 'You',
      ));
    }

    for (final o in _orders) {
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
    final order = _orders.firstWhere(
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
        final name = profile?['first_name'] ?? 'Customer';
        final phone = profile?['phone_number'] ?? '';
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
              Text('Order #${order['id']}',
                  style: appStyle(18, FontWeight.w600, const Color(0xFF111827))),
              SizedBox(height: 12.h),
              _infoRow(Icons.person_outline, name),
              if (phone.isNotEmpty) ...[
                SizedBox(height: 6.h),
                _infoRow(Icons.phone_outlined, phone),
              ],
              SizedBox(height: 6.h),
              _infoRow(Icons.receipt_outlined, 'EGP $total'),
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
                  child: Text('Accept Order',
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
                  Text('View Route →',
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
      CustomSnackBar.displaySuccessMotionToast('Order accepted', context);
    } else if (state is AcceptOrderFailure) {
      CustomSnackBar.displayErrorMotionToast(state.errMessage, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final centerLat = _driverLat ?? 30.0444;
    final centerLng = _driverLng ?? 31.2357;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders Map'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty && !_locationReady
              ? const Center(child: CircularProgressIndicator())
              : AdaptiveMap(
                  initialLatitude: centerLat,
                  initialLongitude: centerLng,
                  initialZoom: _driverLat != null ? 13 : 10,
                  markers: _buildMarkers(),
                  onMarkerTapped: _onMarkerTapped,
                  showMyLocation: true,
                  showMyLocationButton: true,
                ),
    );
  }
}