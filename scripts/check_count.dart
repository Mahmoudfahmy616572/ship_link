import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  const key = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFxeGl6aXF5Ymd0dnJkZmhtbW9jIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4MTcyMjkwNSwiZXhwIjoyMDk3Mjk4OTA1fQ.Tr44VtSoEC7S4CzAsPv07v6jazDLMU8pA1UeiAkB5-s';
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
