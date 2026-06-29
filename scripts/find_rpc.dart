import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  const url = 'https://aqxiziqybgtvrdfhmmoc.supabase.co';
  const key = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFxeGl6aXF5Ymd0dnJkZmhtbW9jIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4MTcyMjkwNSwiZXhwIjoyMDk3Mjk4OTA1fQ.Tr44VtSoEC7S4CzAsPv07v6jazDLMU8pA1UeiAkB5-s';

  // Try various RPC endpoints for raw SQL execution
  for (final fn in ['pg_query', 'exec_sql', 'run_sql', 'query']) {
    final resp = await http.post(
      Uri.parse('$url/rest/v1/rpc/$fn'),
      headers: {
        'apikey': key,
        'Authorization': 'Bearer $key',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'query': 'SELECT 1'}),
    );
    print('rpc/$fn: ${resp.statusCode}');
    if (resp.statusCode == 200) {
      print('  FOUND! Body: ${resp.body}');
    }
  }

  // Check if total_price is really NOT NULL
  final cols = await http.get(
    Uri.parse('$url/rest/v1/orders?limit=1&select=total_price,user_id,status,cart_id'),
    headers: {'apikey': key, 'Authorization': 'Bearer $key'},
  );
  print('Column check: ${cols.statusCode} ${cols.body}');

  // Try inserting without total_price just to see the error
  final uid = '00000000-0000-0000-0000-000000000000';
  // First try to alter column to nullable via service_role insert attempt
  // Actually let me just try inserting with total_price=0
  final testInsert = await http.post(
    Uri.parse('$url/rest/v1/orders'),
    headers: {
      'apikey': key,
      'Authorization': 'Bearer $key',
      'Content-Type': 'application/json',
      'Prefer': 'return=minimal',
    },
    body: jsonEncode({
      'user_id': uid,
      'cart_id': 1,
      'total_price': 0,
      'status': 'pending',
    }),
  );
  print('Insert with total_price=0: ${testInsert.statusCode}');
  if (testInsert.statusCode >= 400) {
    print('Error: ${testInsert.body}');
  } else {
    print('SUCCESS - cleaning up');
    await http.delete(
      Uri.parse('$url/rest/v1/orders?user_id=eq.$uid'),
      headers: {'apikey': key, 'Authorization': 'Bearer $key'},
    );
  }
}
