import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  const supabaseUrl = 'https://aqxiziqybgtvrdfhmmoc.supabase.co';
  const serviceRoleKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFxeGl6aXF5Ymd0dnJkZmhtbW9jIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4MTcyMjkwNSwiZXhwIjoyMDk3Mjk4OTA1fQ.Tr44VtSoEC7S4CzAsPv07v6jazDLMU8pA1UeiAkB5-s';

  // First try a minimal insert to discover valid columns
  print('Testing insert with minimal columns...');
  final testResp = await http.post(
    Uri.parse('$supabaseUrl/rest/v1/products'),
    headers: {
      'apikey': serviceRoleKey,
      'Authorization': 'Bearer $serviceRoleKey',
      'Content-Type': 'application/json',
      'Prefer': 'return=representation',
    },
    body: jsonEncode({
      'name': 'Test Product',
      'description': 'Testing columns',
      'image': 'https://via.placeholder.com/150',
      'price': 9.99,
      'category': 'test',
    }),
  );
  print('Test insert: ${testResp.statusCode}');
  if (testResp.statusCode == 201) {
    final inserted = jsonDecode(testResp.body) as List;
    if (inserted.isNotEmpty) {
      print('Available columns: ${(inserted[0] as Map).keys.join(", ")}');
    }
    // Delete the test row
    await http.delete(
      Uri.parse('$supabaseUrl/rest/v1/products?id=eq.${inserted[0]['id']}'),
      headers: {'apikey': serviceRoleKey, 'Authorization': 'Bearer $serviceRoleKey'},
    );
    print('Test row deleted.');
  } else {
    print('Error: ${testResp.body}');
  }

  // If we get past the test, fetch all and insert for real
  if (testResp.statusCode == 201) {
    print('');
    print('Fetching products from DummyJSON...');
    final resp = await http.get(
      Uri.parse('https://dummyjson.com/products?limit=100'),
    );
    if (resp.statusCode != 200) {
      print('Failed to fetch: ${resp.statusCode}');
      exit(1);
    }
    final data = jsonDecode(resp.body) as Map;
    final products = data['products'] as List;
    print('Fetched ${products.length} products. Inserting...');

    final rows = products.map((p) => {
          'name': p['title'],
          'description': p['description'],
          'image': p['thumbnail'],
          'price': (p['price'] as num).toDouble(),
          'category': p['category'],
          'is_top_seller': false,
        }).toList();

    for (var i = 0; i < rows.length; i += 50) {
      final batch = rows.sublist(i, (i + 50).clamp(0, rows.length));
      final insertResp = await http.post(
        Uri.parse('$supabaseUrl/rest/v1/products'),
        headers: {
          'apikey': serviceRoleKey,
          'Authorization': 'Bearer $serviceRoleKey',
          'Content-Type': 'application/json',
          'Prefer': 'return=minimal',
        },
        body: jsonEncode(batch),
      );
      if (insertResp.statusCode == 201) {
        print('Inserted batch ${i ~/ 50 + 1} (${batch.length} products)');
      } else {
        print('Batch ${i ~/ 50 + 1} failed: ${insertResp.statusCode} ${insertResp.body}');
      }
    }
    print('Done! All products inserted.');
  }
}
