import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/driver/data/repositories/driver_earnings_repository_impl.dart';
import 'package:ship_link/web/driver/cubits/get_orders/get_orders_web_cubit.dart';
import 'package:ship_link/web/driver/cubits/get_accepted_orders/get_accepted_orders_web_cubit.dart';
import 'package:ship_link/web/driver/cubits/get_userdriver_data/get_userdriver_data_web_cubit.dart';
import 'package:ship_link/web/driver/cubits/accept_order/accept_order_web_cubit.dart';

class DriverHomeWeb extends StatefulWidget {
  const DriverHomeWeb({super.key});

  @override
  State<DriverHomeWeb> createState() => _DriverHomeWebState();
}

class _DriverHomeWebState extends State<DriverHomeWeb> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GetOrdersWebCubit>().getOrders();
      context.read<GetAcceptedOrdersWebCubit>().getAcceptedOrders();
    });
  }

  void _refreshAll() {
    context.read<GetOrdersWebCubit>().getOrders();
    context.read<GetAcceptedOrdersWebCubit>().getAcceptedOrders();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width > 768;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isWide ? 32 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGreeting(),
              SizedBox(height: isWide ? 32 : 20),
              _buildStatsRow(isWide),
              SizedBox(height: isWide ? 32 : 20),
              _buildActiveDelivery(isWide),
              SizedBox(height: isWide ? 32 : 20),
              _buildAvailableOrders(isWide),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreeting() {
    return BlocBuilder<GetUserdriverDataWebCubit, GetUserdriverDataWebState>(
      builder: (context, state) {
        final name = state is GetUserdriverDataSuccess
            ? state.userData.data?.name ?? 'Driver'
            : 'Driver';
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hello, $name', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    const Text('Driver Dashboard', style: TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(radius: 4, backgroundColor: Colors.white),
                    SizedBox(width: 6),
                    Text('Online', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsRow(bool isWide) {
    return BlocBuilder<GetAcceptedOrdersWebCubit, GetAcceptedOrdersWebState>(
      builder: (context, state) {
        final count = state is GetAcceptedOrdersSuccess
            ? state.getOrder.data?.order?.length ?? 0
            : 0;
        final cards = [
          _statCard(Icons.delivery_dining, '$count', 'Active', AppColors.primary),
          _ratingCard(),
          _earningsCard(),
        ];
        if (isWide) {
          return Row(children: cards.map((c) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: c))).toList());
        }
        return Column(children: cards.map((c) => Padding(padding: const EdgeInsets.only(bottom: 12), child: c)).toList());
      },
    );
  }

  Widget _ratingCard() {
    final driverId = Supabase.instance.client.auth.currentUser?.id;
    if (driverId == null) return _statCard(Icons.star, '0.0 (0)', 'Rating', const Color(0xFFF59E0B));
    return FutureBuilder<Map<String, dynamic>>(
      future: _getDriverRating(driverId),
      builder: (context, snapshot) {
        final avg = snapshot.data?['avg'] as double? ?? 0;
        final cnt = snapshot.data?['count'] as int? ?? 0;
        return _statCard(Icons.star, '${avg.toStringAsFixed(1)} ($cnt)', 'Rating', const Color(0xFFF59E0B));
      },
    );
  }

  Widget _earningsCard() {
    final driverId = Supabase.instance.client.auth.currentUser?.id;
    if (driverId == null) return _statCard(Icons.attach_money, '\$0', 'Today', const Color(0xFF10B981));
    return FutureBuilder<double>(
      future: DriverEarningsRepositoryImpl().getTodayEarnings(driverId).then((r) => r.fold((_) => 0.0, (v) => v)),
      builder: (context, snapshot) {
        final value = snapshot.data ?? 0;
        return _statCard(Icons.attach_money, '\$${value.toStringAsFixed(0)}', 'Today', const Color(0xFF10B981));
      },
    );
  }

  Widget _statCard(IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>> _getDriverRating(String driverId) async {
    try {
      final data = await Supabase.instance.client.from('driver_ratings').select('rating').eq('driver_id', driverId);
      if (data.isEmpty) return {'avg': 0.0, 'count': 0};
      double sum = 0;
      for (final row in data) { sum += (row['rating'] as num).toDouble(); }
      return {'avg': sum / data.length, 'count': data.length};
    } catch (_) {
      return {'avg': 0.0, 'count': 0};
    }
  }

  Widget _buildActiveDelivery(bool isWide) {
    return BlocBuilder<GetAcceptedOrdersWebCubit, GetAcceptedOrdersWebState>(
      builder: (context, state) {
        if (state is GetAcceptedOrdersSuccess && (state.getOrder.data?.order?.length ?? 0) > 0) {
          final order = state.getOrder.data!.order!.first;
          final status = order.status?.toLowerCase() ?? '';
          final statusSteps = {'accepted': 0, 'picked_up': 1, 'shipped': 2, 'delivered': 3};
          final currentStep = statusSteps[status] ?? 0;
          final steps = ['Accepted', 'Picked Up', 'In Transit', 'Delivered'];
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(8)),
                      child: const Text('Active Delivery', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFD97706))),
                    ),
                    const Spacer(),
                    Text('#${order.id ?? ''}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: List.generate(steps.length, (i) => Expanded(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 6,
                          backgroundColor: i <= currentStep ? AppColors.primary : const Color(0xFFD1D5DB),
                        ),
                        const SizedBox(height: 6),
                        Text(steps[i], style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: i <= currentStep ? AppColors.primary : const Color(0xFF9CA3AF)), textAlign: TextAlign.center),
                      ],
                    ),
                  )),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.person_outline, size: 18, color: Color(0xFF6B7280)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(order.customerName ?? order.user?.firstName ?? 'Customer', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
                    Text('\$${order.totalPrice ?? '0'}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF10B981))),
                  ],
                ),
                const SizedBox(height: 16),
                _buildStatusActions(context, order, status),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildStatusActions(BuildContext context, dynamic order, String status) {
    Widget btn(String label, IconData icon, Color color, VoidCallback onTap, {bool outlined = false}) {
      if (outlined) {
        return OutlinedButton.icon(
          onPressed: onTap,
          icon: Icon(icon, size: 18),
          label: Text(label),
          style: OutlinedButton.styleFrom(foregroundColor: color, side: BorderSide(color: color), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
        );
      }
      return ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
      );
    }

    List<Widget> actions = [];
    if (status == 'accepted') {
      actions = [
        Expanded(child: btn('Mark Picked Up', Icons.check_circle_outline, AppColors.primary, () async { await context.read<AcceptOrderWebCubit>().markPickedUp(orderId: order.id); _refreshAll(); })),
        const SizedBox(width: 12),
        SizedBox(height: 40, child: btn('Cancel', Icons.cancel_outlined, const Color(0xFFDC2626), () async { await context.read<AcceptOrderWebCubit>().cancelOrder(orderId: order.id); _refreshAll(); }, outlined: true)),
      ];
    } else if (status == 'picked_up') {
      actions = [
        Expanded(child: btn('Mark Shipped', Icons.local_shipping, const Color(0xFFD97706), () async { await context.read<AcceptOrderWebCubit>().markShipped(orderId: order.id); _refreshAll(); })),
        const SizedBox(width: 12),
        SizedBox(height: 40, child: btn('Cancel', Icons.cancel_outlined, const Color(0xFFDC2626), () async { await context.read<AcceptOrderWebCubit>().cancelOrder(orderId: order.id); _refreshAll(); }, outlined: true)),
      ];
    } else if (status == 'shipped') {
      actions = [
        Expanded(child: btn('Mark Delivered', Icons.check_circle, const Color(0xFF059669), () async { await context.read<AcceptOrderWebCubit>().markDelivered(orderId: order.id); _refreshAll(); })),
        const SizedBox(width: 12),
        SizedBox(height: 40, child: btn('Cancel', Icons.cancel_outlined, const Color(0xFFDC2626), () async { await context.read<AcceptOrderWebCubit>().cancelOrder(orderId: order.id); _refreshAll(); }, outlined: true)),
      ];
    }
    return Row(children: actions);
  }

  Widget _buildAvailableOrders(bool isWide) {
    return BlocBuilder<GetOrdersWebCubit, GetOrdersWebState>(
      builder: (context, state) {
        final orders = state is GetOrdersSuccess
            ? state.getOrder.data?.order?.where((o) => o.status?.toLowerCase() == 'pending').toList()
            : <dynamic>[];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Available Orders', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const Spacer(),
                if (orders != null) Text('${orders.length}', style: const TextStyle(fontSize: 14, color: Color(0xFF9CA3AF))),
              ],
            ),
            const SizedBox(height: 12),
            if (state is GetOrdersLoading)
              const Center(child: CircularProgressIndicator())
            else if (orders == null || orders.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    const Icon(Icons.inbox_outlined, size: 48, color: Color(0xFFD1D5DB)),
                    const SizedBox(height: 12),
                    Text('No orders available', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey[400])),
                    const SizedBox(height: 4),
                    Text('Check back later', style: TextStyle(fontSize: 14, color: Colors.grey[300])),
                  ],
                ),
              )
            else
              ...orders.map((order) => _orderCard(context, order, isWide)),
          ],
        );
      },
    );
  }

  Widget _orderCard(BuildContext context, dynamic order, bool isWide) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: const Color(0xFFF0F0F0), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.store, color: Color(0xFF6B7280), size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Order #${order.id ?? ''}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(order.customerName ?? order.user?.firstName ?? 'Customer', style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(8)),
                child: Text(order.status ?? 'Pending', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFD97706))),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.person_outline, size: 16, color: Color(0xFF6B7280)),
              const SizedBox(width: 8),
              Expanded(child: Text(order.user?.firstName ?? 'Customer', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
              Text('\$${order.totalPrice ?? '0'}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF10B981))),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: isWide ? 200 : double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                await context.read<AcceptOrderWebCubit>().acceptOrders(orderId: order.id);
                _refreshAll();
              },
              icon: const Icon(Icons.check, size: 18),
              label: const Text('Accept Order', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
