import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  print('Fetching products from DummyJSON...');
  final response = await http.get(
    Uri.parse('https://dummyjson.com/products?limit=100'),
  );

  if (response.statusCode != 200) {
    print('Failed to fetch: ${response.statusCode}');
    exit(1);
  }

  final data = jsonDecode(response.body) as Map;
  final products = data['products'] as List;

  print('Fetched ${products.length} products. Generating SQL...');

  final buffer = StringBuffer();
  buffer.writeln('-- Generated product inserts for ShipLink');
  buffer.writeln('-- Source: DummyJSON API');
  buffer.writeln();

  final categories = <String, int>{};
  int catId = 0;

  for (final p in products) {
    final esc = (String s) => s.replaceAll("'", "''");
    final title = esc(p['title'] as String);
    final description = esc(p['description'] as String);
    final image = esc(p['thumbnail'] as String);
    final price = (p['price'] as num).toDouble();
    final category = esc(p['category'] as String);
    final stock = (p['stock'] as num).toInt();

    // Track unique categories
    if (!categories.containsKey(category)) {
      catId++;
      categories[category] = catId;
    }

    buffer.writeln("INSERT INTO public.products (name, description, image, price, qty, category, is_top_seller)");
    buffer.writeln("VALUES ('$title', '$description', '$image', $price, $stock, '$category', false);");
  }

  buffer.writeln();
  buffer.writeln('-- Done! ${products.length} products inserted.');

  final outputPath = '${Directory.current.path}\\scripts\\seed_products.sql';
  await File(outputPath).writeAsString(buffer.toString());
  print('SQL file written to: $outputPath');
  print('');
  print('Categories found: ${categories.keys.join(', ')}');
  print('');
  print('Instructions:');
  print('1. Open your Supabase Dashboard');
  print('2. Go to SQL Editor');
  print('3. Copy the content of seed_products.sql');
  print('4. Paste and Run');
  print('');
  print('Note: The INSERT policy on the products table must allow inserts.');
  print('If you get a permissions error, run this SQL first:');
  print('');
  print('  CREATE POLICY "Authenticated users can insert products" ON products');
  print('    FOR INSERT WITH CHECK (auth.role() = \'authenticated\');');
}
