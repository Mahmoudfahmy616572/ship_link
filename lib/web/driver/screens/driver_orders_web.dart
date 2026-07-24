import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/web/driver/cubits/get_orders/get_orders_web_cubit.dart';
import 'package:ship_link/web/driver/cubits/get_accepted_orders/get_accepted_orders_web_cubit.dart';
import 'package:ship_link/web/driver/cubits/accept_order/accept_order_web_cubit.dart';

class DriverOrdersWeb extends StatefulWidget {
  const DriverOrdersWeb({super.key});

  @override
  State<DriverOrdersWeb> createState() => _DriverOrdersWebState();
}

class _DriverOrdersWebState extends State<DriverOrdersWeb> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _refreshAll() {
    context.read<GetOrdersWebCubit>().getOrders();
    context.read<GetAcceptedOrdersWebCubit>().getAcceptedOrders();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 768;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(isWide ? 32 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('My Orders', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: Colors.white,
                  unselectedLabelColor: const Color(0xFF6B7280),
                  indicator: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: 'Available'),
                    Tab(text: 'Accepted'),
                    Tab(text: 'Completed'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAvailableOrders(isWide),
                    _buildAcceptedOrders(isWide),
                    _buildCompletedOrders(isWide),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvailableOrders(bool isWide) {
    return BlocBuilder<GetOrdersWebCubit, GetOrdersWebState>(
      builder: (context, state) {
        if (state is GetOrdersLoading) return const Center(child: CircularProgressIndicator());
        if (state is GetOrdersError) return Center(child: Text(state.message));
        if (state is GetOrdersSuccess) {
          final orders = state.getOrder.data?.order?.where((o) => o.status?.toLowerCase() == 'pending').toList();
          if (orders == null || orders.isEmpty) return _emptyState('No available orders', Icons.inbox_outlined);
          return isWide
              ? GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 2.5, crossAxisSpacing: 16, mainAxisSpacing: 12),
                  itemCount: orders.length,
                  itemBuilder: (_, i) => _orderCard(context, orders[i]),
                )
              : ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (_, i) => Padding(padding: const EdgeInsets.only(bottom: 12), child: _orderCard(context, orders[i])),
                );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildAcceptedOrders(bool isWide) {
    return BlocBuilder<GetAcceptedOrdersWebCubit, GetAcceptedOrdersWebState>(
      builder: (context, state) {
        if (state is GetAcceptedOrdersLoading) return const Center(child: CircularProgressIndicator());
        if (state is GetAcceptedOrdersError) return Center(child: Text(state.message));
        if (state is GetAcceptedOrdersSuccess) {
          final orders = state.getOrder.data?.order?.where((o) => o.status?.toLowerCase() == 'accepted' || o.status?.toLowerCase() == 'picked_up' || o.status?.toLowerCase() == 'shipped').toList();
          if (orders == null || orders.isEmpty) return _emptyState('No accepted orders', Icons.check_circle_outline);
          return isWide
              ? GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 2.5, crossAxisSpacing: 16, mainAxisSpacing: 12),
                  itemCount: orders.length,
                  itemBuilder: (_, i) => _acceptedCard(context, orders[i]),
                )
              : ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (_, i) => Padding(padding: const EdgeInsets.only(bottom: 12), child: _acceptedCard(context, orders[i])),
                );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildCompletedOrders(bool isWide) {
    return BlocBuilder<GetAcceptedOrdersWebCubit, GetAcceptedOrdersWebState>(
      builder: (context, state) {
        if (state is GetAcceptedOrdersLoading) return const Center(child: CircularProgressIndicator());
        if (state is GetAcceptedOrdersError) return Center(child: Text(state.message));
        if (state is GetAcceptedOrdersSuccess) {
          final orders = state.getOrder.data?.order?.where((o) => o.status?.toLowerCase() == 'delivered').toList();
          if (orders == null || orders.isEmpty) return _emptyState('No completed orders', Icons.checklist);
          return isWide
              ? GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 2.5, crossAxisSpacing: 16, mainAxisSpacing: 12),
                  itemCount: orders.length,
                  itemBuilder: (_, i) => _acceptedCard(context, orders[i]),
                )
              : ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (_, i) => Padding(padding: const EdgeInsets.only(bottom: 12), child: _acceptedCard(context, orders[i])),
                );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _emptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 56, color: const Color(0xFFD1D5DB)),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF9CA3AF))),
        ],
      ),
    );
  }

  Widget _orderCard(BuildContext context, dynamic order) {
    return Container(
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
              Text('\$${order.totalPrice ?? '0'}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF10B981))),
            ],
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                await context.read<AcceptOrderWebCubit>().acceptOrders(orderId: order.id);
                _refreshAll();
              },
              icon: const Icon(Icons.check, size: 18),
              label: const Text('Accept', style: TextStyle(color: Colors.white)),
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

  Widget _acceptedCard(BuildContext context, dynamic order) {
    final status = order.status?.toLowerCase() ?? '';
    final statusColors = {
      'accepted': const Color(0xFF2563EB),
      'picked_up': const Color(0xFFD97706),
      'shipped': const Color(0xFF7C3AED),
      'delivered': const Color(0xFF059669),
    };
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: const Color(0xFFF0F0F0), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.local_shipping, color: Color(0xFF6B7280), size: 24),
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
            decoration: BoxDecoration(
              color: (statusColors[status] ?? Colors.grey).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(order.status ?? '', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: statusColors[status])),
          ),
          const SizedBox(width: 12),
          Text('\$${order.totalPrice ?? '0'}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF10B981))),
        ],
      ),
    );
  }
}
