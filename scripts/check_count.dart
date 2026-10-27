import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  final key = Platform.environment['SUPABASE_SERVICE_ROLE'] ?? '';
  final resp = await http.get(
    Uri.parse('https://aqxiziqybgtvrdfhmmoc.supabase.co/rest/v1/products?select=count'),
    headers: {'apikey': key, 'Authorization': 'Bearer $key', 'Accept': 'application/json'},
  );
  print('Status: ${resp.statusCode}');
  print('Body: ${resp.body}');
  // Also fetch a few rows
  final resp2 = await http.get(
    Uri.parse('https://aqxiziqybgtvrdfhmmoc.supabase.co/rest/v1/products?limit=3&select=id,name'),
    headers: {'apikey': key, 'Authorization': 'Bearer $key'},
  );
  if (resp2.statusCode == 200) {
    final rows = jsonDecode(resp2.body) as List;
    print('Sample rows: ${rows.length}');
    for (final r in rows) {
      print('  id=${r['id']} name=${r['name']}');
    }
  }
}
