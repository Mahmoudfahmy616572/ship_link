import 'package:flutter/material.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/services/supabase_service.dart';
import 'package:ship_link/core/widgets/app_style.dart';
import 'package:ship_link/core/widgets/shimmer/shimmer_loading.dart';
import 'package:ship_link/admin/widgets/admin_data_table.dart';
import 'package:ship_link/core/utils/sizer.dart';

class AdminOrders extends StatefulWidget {
  const AdminOrders({super.key});
  static String routName = '/admin/orders';

  @override
  State<AdminOrders> createState() => _AdminOrdersState();
}

class _AdminOrdersState extends State<AdminOrders> {
  final _supabase = SupabaseService();
  List<Map<String, dynamic>> _orders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final orders = await _supabase.getOrders();
    setState(() {
      _orders = orders;
      _loading = false;
    });
  }

  Future<void> _updateStatus(int orderId, String status) async {
    await _supabase.client
        .from('orders')
        .update({'status': status}).eq('id', orderId);
    _loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return ShimmerLoading.orderHistory();
    }
    return AdminDataTable(
      columns: const ['ID', 'User', 'Total', 'Status', 'Actions'],
      rows: _orders.map((o) {
        return DataRow(cells: [
          DataCell(Text('${o['id']}')),
          DataCell(Text('${o['user_id']?.toString().substring(0, 8) ?? 'N/A'}...')),
          DataCell(Text('\$${o['total_price']}')),
          DataCell(_statusChip(o['status'] ?? 'pending')),
          DataCell(Row(
            children: [
              if (o['status'] == 'pending')
                IconButton(
                  icon: const Icon(Icons.check, color: Colors.green),
                  onPressed: () => _updateStatus(o['id'], 'accepted'),
                ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _updateStatus(o['id'], 'cancelled'),
              ),
            ],
          )),
        ]);
      }).toList(),
    );
  }

  Widget _statusChip(String status) {
    final colors = {
      'pending': AppColors.pending,
      'accepted': AppColors.primary,
      'delivered': AppColors.success,
      'cancelled': AppColors.error,
    };
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: (colors[status] ?? AppColors.textDisabled).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(status,
          style: appStyle(12, FontWeight.bold, colors[status] ?? Colors.grey)),
    );
  }
}