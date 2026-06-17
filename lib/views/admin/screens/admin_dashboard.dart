import 'package:flutter/material.dart';
import '../../../services/supabase_service.dart';
import '../widgets/admin_stats_card.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});
  static String routName = '/admin/dashboard';

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final _supabase = SupabaseService();
  Map<String, int> _stats = {};

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final orders = await _supabase.getOrders();
    final products = await _supabase.getProducts();
    final pending = orders.where((o) => o['status'] == 'pending').length;
    setState(() {
      _stats = {
        'total_orders': orders.length,
        'pending': pending,
        'products': products.length,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;
    return GridView.count(
      crossAxisCount: isWide ? 4 : 2,
      padding: const EdgeInsets.all(20),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      children: [
        AdminStatsCard(
          title: 'Total Orders',
          value: '${_stats['total_orders'] ?? 0}',
          icon: Icons.receipt_long,
          color: Colors.blue,
        ),
        AdminStatsCard(
          title: 'Pending',
          value: '${_stats['pending'] ?? 0}',
          icon: Icons.pending_actions,
          color: Colors.orange,
        ),
        AdminStatsCard(
          title: 'Products',
          value: '${_stats['products'] ?? 0}',
          icon: Icons.inventory_2,
          color: Colors.green,
        ),
        AdminStatsCard(
          title: 'Drivers',
          value: '0',
          icon: Icons.local_shipping,
          color: Colors.purple,
        ),
      ],
    );
  }
}
