import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  const key = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFxeGl6aXF5Ymd0dnJkZmhtbW9jIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4MTcyMjkwNSwiZXhwIjoyMDk3Mjk4OTA1fQ.Tr44VtSoEC7S4CzAsPv07v6jazDLMU8pA1UeiAkB5-s';
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
