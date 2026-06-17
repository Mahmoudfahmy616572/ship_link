import 'package:flutter/material.dart';
import '../../../services/supabase_service.dart';
import '../widgets/admin_data_table.dart';

class AdminProducts extends StatefulWidget {
  const AdminProducts({super.key});
  static String routName = '/admin/products';

  @override
  State<AdminProducts> createState() => _AdminProductsState();
}

class _AdminProductsState extends State<AdminProducts> {
  final _supabase = SupabaseService();
  List<Map<String, dynamic>> _products = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final products = await _supabase.getProducts();
    setState(() {
      _products = products;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return AdminDataTable(
      columns: const ['ID', 'Name', 'Price', 'Category', 'Top Seller'],
      rows: _products.map((p) {
        return DataRow(cells: [
          DataCell(Text('${p['id']}')),
          DataCell(SizedBox(width: 150, child: Text('${p['name']}'))),
          DataCell(Text('\$${p['price']}')),
          DataCell(Text('${p['category'] ?? '-'}')),
          DataCell(Icon(
            p['is_top_seller'] == true ? Icons.star : Icons.star_border,
            color: p['is_top_seller'] == true ? Colors.amber : Colors.grey,
          )),
        ]);
      }).toList(),
    );
  }
}
