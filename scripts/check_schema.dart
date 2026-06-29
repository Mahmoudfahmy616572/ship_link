import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  const key = '***REMOVED***';
  final resp = await http.get(
    Uri.parse('https://aqxiziqybgtvrdfhmmoc.supabase.co/rest/v1/products?limit=1'),
    headers: {'apikey': key, 'Authorization': 'Bearer $key'},
  );
  if (resp.body.isNotEmpty && resp.body != '[]') {
    final row = jsonDecode(resp.body) as List;
    if (row.isNotEmpty) {
      print('Columns: ${(row[0] as Map).keys.join(", ")}');
    } else {
      print('No rows found - table is empty');
    }
  } else {
    print('Status: ${resp.statusCode}');
    print('Body: ${resp.body}');
  }
}
