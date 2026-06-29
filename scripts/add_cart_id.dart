import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  const projectRef = 'aqxiziqybgtvrdfhmmoc';
  const serviceRoleKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFxeGl6aXF5Ymd0dnJkZmhtbW9jIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4MTcyMjkwNSwiZXhwIjoyMDk3Mjk4OTA1fQ.Tr44VtSoEC7S4CzAsPv07v6jazDLMU8pA1UeiAkB5-s';

  // Try Management API
  print('Trying Management API with service_role key...');
  final mgmtResp = await http.post(
    Uri.parse('https://api.supabase.com/v1/projects/$projectRef/database/query'),
    headers: {
      'Authorization': 'Bearer $serviceRoleKey',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'query': 'ALTER TABLE orders ADD COLUMN IF NOT EXISTS cart_id INT;',
    }),
  );
  print('Management API: ${mgmtResp.statusCode} ${mgmtResp.body}');

  if (mgmtResp.statusCode == 200 || mgmtResp.statusCode == 201) {
    print('SUCCESS! cart_id column added to orders table.');
    return;
  }

  // Try the /sql endpoint
  print('Trying /sql endpoint...');
  final sqlResp = await http.post(
    Uri.parse('https://$projectRef.supabase.co/sql'),
    headers: {
      'Authorization': 'Bearer $serviceRoleKey',
      'Content-Type': 'text/plain',
    },
    body: 'ALTER TABLE orders ADD COLUMN IF NOT EXISTS cart_id INT;',
  );
  print('/sql endpoint: ${sqlResp.statusCode} ${sqlResp.body}');

  if (sqlResp.statusCode == 200 || sqlResp.statusCode == 201) {
    print('SUCCESS! cart_id column added to orders table.');
    return;
  }

  // Try via RPC with execute_sql
  print('Trying rpc/execute_sql...');
  final rpcResp = await http.post(
    Uri.parse('https://$projectRef.supabase.co/rest/v1/rpc/execute_sql'),
    headers: {
      'apikey': serviceRoleKey,
      'Authorization': 'Bearer $serviceRoleKey',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({'query_text': 'ALTER TABLE orders ADD COLUMN IF NOT EXISTS cart_id INT;'}),
  );
  print('rpc/execute_sql: ${rpcResp.statusCode} ${rpcResp.body}');

  if (rpcResp.statusCode == 200 || rpcResp.statusCode == 201) {
    print('SUCCESS! cart_id column added to orders table.');
    return;
  }

  // Try via pg_ddl extension
  print('Trying rpc/pg_ddl_exec...');
  final ddlResp = await http.post(
    Uri.parse('https://$projectRef.supabase.co/rest/v1/rpc/pg_ddl_exec'),
    headers: {
      'apikey': serviceRoleKey,
      'Authorization': 'Bearer $serviceRoleKey',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({'sql': 'ALTER TABLE orders ADD COLUMN IF NOT EXISTS cart_id INT;'}),
  );
  print('rpc/pg_ddl_exec: ${ddlResp.statusCode} ${ddlResp.body}');

  print('');
  print('Could not add column via API.');
  print('Please go to https://supabase.com/dashboard/project/$projectRef/sql/new');
  print('and run:');
  print('  ALTER TABLE orders ADD COLUMN cart_id INT;');
}
