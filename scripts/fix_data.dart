import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final key = '***REMOVED***';

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
