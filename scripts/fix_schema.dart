import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  const url = 'https://aqxiziqybgtvrdfhmmoc.supabase.co';
  const key = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFxeGl6aXF5Ymd0dnJkZmhtbW9jIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4MTcyMjkwNSwiZXhwIjoyMDk3Mjk4OTA1fQ.Tr44VtSoEC7S4CzAsPv07v6jazDLMU8pA1UeiAkB5-s';

  // Try /sql endpoint (Supabase's raw SQL API)
  final sql = '''
DROP POLICY IF EXISTS "Users can insert orders" ON orders;
CREATE POLICY "Users can insert orders" ON orders
  FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can view own orders" ON orders;
CREATE POLICY "Users can view own orders" ON orders
  FOR SELECT USING (auth.uid() = user_id OR auth.uid() = driver_id);

DROP POLICY IF EXISTS "Users can manage own favourites" ON favourites;
CREATE POLICY "Users can manage own favourites" ON favourites
  FOR ALL USING (auth.uid() = user_id);
''';

  final resp = await http.post(
    Uri.parse('$url/sql'),
    headers: {
      'apikey': key,
      'Authorization': 'Bearer $key',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({'query': sql}),
  );
  print('SQL endpoint: ${resp.statusCode}');
  if (resp.body.isNotEmpty) print('Body: ${resp.body.substring(0, resp.body.length.clamp(0, 500))}');

  // Verify: try to insert a test order with service_role key (bypasses RLS)
  final uid = '00000000-0000-0000-0000-000000000000'; // won't work but tests endpoint
  final testResp = await http.post(
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
      'status': 'pending',
    }),
  );
  print('Test insert: ${testResp.statusCode}');
  if (testResp.statusCode >= 400) {
    print('Error: ${testResp.body}');
  } else {
    print('Insert worked, cleaning up...');
    await http.delete(
      Uri.parse('$url/rest/v1/orders?user_id=eq.$uid'),
      headers: {'apikey': key, 'Authorization': 'Bearer $key'},
    );
  }

  // List existing policies on orders table
  final polResp = await http.get(
    Uri.parse('$url/rest/v1/pg_policies?tablename=eq.orders&select=*'),
    headers: {'apikey': key, 'Authorization': 'Bearer $key'},
  );
  print('Policies on orders: ${polResp.statusCode}');
  if (polResp.body.isNotEmpty && polResp.body != '[]') {
    print(polResp.body);
  } else {
    print('No policies found via REST, trying raw query...');
    // Try creating via a simpler approach
    final simpleSql = '''
    BEGIN;
    ALTER TABLE orders DISABLE ROW LEVEL SECURITY;
    ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
    CREATE POLICY "allow_all_orders" ON orders FOR ALL USING (true);
    COMMIT;
    ''';
    final resp2 = await http.post(
      Uri.parse('$url/sql'),
      headers: {
        'apikey': key,
        'Authorization': 'Bearer $key',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'query': simpleSql}),
    );
    print('Simple fix: ${resp2.statusCode} ${resp2.body}');
  }
}
