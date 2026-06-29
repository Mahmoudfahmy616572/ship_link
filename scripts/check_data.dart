import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFxeGl6aXF5Ymd0dnJkZmhtbW9jIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODE3MjI5MDUsImV4cCI6MjA5NzI5ODkwNX0.vohe0h4gzDZSRttscc6c2RXREIv6Nt7WawxSoavFG6w';
  
  // Test with anon key (same as app uses)
  final resp = await http.get(
    Uri.parse('https://aqxiziqybgtvrdfhmmoc.supabase.co/rest/v1/products?limit=5'),
    headers: {'apikey': anonKey, 'Authorization': 'Bearer $anonKey'},
  );
  if (resp.statusCode == 200) {
    final rows = jsonDecode(resp.body) as List;
    print('Status: ${resp.statusCode}');
    print('Count: ${rows.length}');
    if (rows.isNotEmpty) {
      print('Columns: ${(rows[0] as Map).keys.join(", ")}');
      print('First product: ${rows[0]['name']} - \$${rows[0]['price']}');
      print('Image URL: ${rows[0]['image']}');
    }
  } else {
    print('Error: ${resp.statusCode} - ${resp.body}');
  }
}
