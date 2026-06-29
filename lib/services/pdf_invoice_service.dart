import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PdfInvoiceService {
  final _supabase = Supabase.instance.client;

  Future<Map<String, dynamic>?> _loadOrder(int orderId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;
    return await _supabase
        .from('orders')
        .select()
        .eq('id', orderId)
        .eq('user_id', userId)
        .maybeSingle();
  }

  Future<List<Map<String, dynamic>>> _loadItems(int orderId) async {
    return await _supabase
        .from('order_items')
        .select('*, products(*)')
        .eq('order_id', orderId);
  }

  Future<Map<String, dynamic>?> _loadProfile(String userId) async {
    return await _supabase
        .from('profiles')
        .select('name, email, phone_number, address')
        .eq('id', userId)
        .maybeSingle();
  }

  Future<File> generate(int orderId) async {
    final order = await _loadOrder(orderId);
    if (order == null) throw Exception('Order not found');
    final userId = _supabase.auth.currentUser?.id ?? '';
    final profile = await _loadProfile(userId);
    final items = await _loadItems(orderId);

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (ctx) => [
          pw.Header(
            level: 0,
            child: pw.Text('ShipLink Invoice', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          ),
          pw.SizedBox(height: 20),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Order #${order['id']}', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  pw.Text('Date: ${order['created_at'].toString().substring(0, 10)}'),
                  pw.Text('Status: ${order['status']}'),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('Bill To:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text(profile?['name'] ?? ''),
                  pw.Text(profile?['email'] ?? ''),
                  pw.Text(profile?['phone_number'] ?? ''),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 30),
          pw.Table.fromTextArray(
            headers: ['#', 'Product', 'Qty', 'Price', 'Total'],
            data: List.generate(items.length, (i) {
              final item = items[i];
              final product = item['products'] as Map? ?? {};
              final qty = (item['quantity'] as num?)?.toInt() ?? 1;
              final price = (product?['price'] as num?)?.toDouble() ?? 0;
              return [
                '${i + 1}',
                product?['name'] ?? '',
                '$qty',
                '\$${price.toStringAsFixed(2)}',
                '\$${(price * qty).toStringAsFixed(2)}',
              ];
            }),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
            cellAlignments: {
              0: pw.Alignment.center,
              1: pw.Alignment.centerLeft,
              2: pw.Alignment.center,
              3: pw.Alignment.centerRight,
              4: pw.Alignment.centerRight,
            },
          ),
          pw.SizedBox(height: 20),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('Total: \$${(order['total_price'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                      style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                ],
              ),
            ],
          ),
          if (order['delivery_address'] != null) ...[
            pw.SizedBox(height: 20),
            pw.Text('Delivery Address:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text(order['delivery_address']),
          ],
          pw.SizedBox(height: 40),
          pw.Text('Thank you for your purchase!', style: pw.TextStyle(fontSize: 12, color: PdfColors.grey)),
        ],
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/invoice_$orderId.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  Future<void> share(int orderId) async {
    final file = await generate(orderId);
    await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
  }
}
