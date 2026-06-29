import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final key = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFxeGl6aXF5Ymd0dnJkZmhtbW9jIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4MTcyMjkwNSwiZXhwIjoyMDk3Mjk4OTA1fQ.Tr44VtSoEC7S4CzAsPv07v6jazDLMU8pA1UeiAkB5-s';

  // Clear cache entries via a simple function call (we'll use a stored procedure approach)
  // Instead, let's just verify data & tell user to clear app cache
  final resp = await http.get(
    Uri.parse('https://aqxiziqybgtvrdfhmmoc.supabase.co/rest/v1/products?select=count'),
    headers: {'apikey': key, 'Authorization': 'Bearer $key'},
  );
  print('Total products: ${resp.body}');
  
  // Set a few products as top_seller so they appear
  final updateResp = await http.patch(
    Uri.parse('https://aqxiziqybgtvrdfhmmoc.supabase.co/rest/v1/products?id=in.(1,2,3,4,5,6)'),
    headers: {
      'apikey': key,
      'Authorization': 'Bearer $key',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({'is_top_seller': true}),
  );
  print('Top sellers update: ${updateResp.statusCode}');
}
