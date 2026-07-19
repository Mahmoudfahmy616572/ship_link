import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminRemoteDataSource {
  SupabaseClient get _supabase => Supabase.instance.client;

  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    final user = response.user;
    if (user == null) {
      throw Exception('Invalid email or password');
    }
    final admin = await _supabase
        .from('admins')
        .select('id, email, full_name, role, is_active')
        .eq('id', user.id)
        .maybeSingle();
    if (admin == null || admin['is_active'] != true) {
      await _supabase.auth.signOut();
      throw Exception('You are not authorized as an admin');
    }
    return admin;
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // بنتأكد لو فيه أدمن محفوظ في الـ session ونرجع بياناته من غير ما يدخل باسورد تاني
  Future<Map<String, dynamic>?> checkSession() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;
    final admin = await _supabase
        .from('admins')
        .select('id, email, full_name, role, is_active')
        .eq('id', user.id)
        .maybeSingle();
    if (admin == null || admin['is_active'] != true) {
      await _supabase.auth.signOut();
      return null;
    }
    return admin;
  }

  Future<Map<String, dynamic>> getDashboardStats({String period = 'all'}) async {
    // بنجيب عدد الصفوف لكل جدول (من غير limit عشان نعرف العدد الكلي)
    final r1 = await _supabase.from('profiles').select('id');
    final r2 = await _supabase.from('drivers').select('id');
    final r4 = await _supabase.from('products').select('id');
    final users = r1.length;
    final drivers = r2.length;
    final products = r4.length;

    // نحسب بداية الفترة حسب المدة المختارة
    DateTime from = DateTime(2000);
    if (period == 'daily') {
      from = DateTime.now().subtract(const Duration(days: 1));
    } else if (period == 'weekly') {
      from = DateTime.now().subtract(const Duration(days: 7));
    } else if (period == 'monthly') {
      from = DateTime.now().subtract(const Duration(days: 30));
    }
    final fromIso = from.toIso8601String();

    final ordersData = await _supabase
        .from('orders')
        .select('id, total_price, status, created_at')
        .gte('created_at', fromIso);
    final orders = ordersData.length;
    double revenue = 0;
    final Map<String, int> statusCounts = {};
    for (final o in ordersData) {
      if (o['status'] == 'delivered' && o['total_price'] is num) {
        revenue += (o['total_price'] as num).toDouble();
      }
      final s = o['status'] as String? ?? 'unknown';
      statusCounts[s] = (statusCounts[s] ?? 0) + 1;
    }

    // اتجاه الطلبات: عدد الطلبات لكل يوم في آخر 7 أيام
    final trendData = await _supabase
        .from('orders')
        .select('created_at')
        .gte('created_at', DateTime.now().subtract(const Duration(days: 7)).toIso8601String())
        .order('created_at', ascending: true);
    final Map<String, int> trend = {};
    for (final o in trendData) {
      final d = (o['created_at']?.toString() ?? '').substring(0, 10);
      if (d.isNotEmpty) trend[d] = (trend[d] ?? 0) + 1;
    }

    // إحصائيات المنتجات: النشط/غير النشط + المخزون المنخفض + التوزيع حسب الفئة
    final productsData = await _supabase.from('products').select('status, qty, category');
    int activeProducts = 0;
    int lowStock = 0;
    final Map<String, int> byCategory = {};
    for (final p in productsData) {
      if (p['status'] == 1) activeProducts++;
      if (p['qty'] is int && (p['qty'] as int) <= 5) lowStock++;
      final c = p['category']?.toString();
      if (c != null && c.isNotEmpty) byCategory[c] = (byCategory[c] ?? 0) + 1;
    }

    return {
      'users': users,
      'drivers': drivers,
      'orders': orders,
      'products': products,
      'activeProducts': activeProducts,
      'lowStock': lowStock,
      'productByCategory': byCategory,
      'revenue': revenue,
      'statusCounts': statusCounts,
      'trend': trend,
      'period': period,
    };
  }

  Future<List<Map<String, dynamic>>> getUsers({
    int limit = 50,
    int offset = 0,
    String? search,
  }) async {
    final base = _supabase
        .from('profiles')
        .select('id, email, name, phone_number, role, created_at');
    var filtered = base;
    if (search != null && search.isNotEmpty) {
      filtered = filtered.or('email.ilike.%$search%,name.ilike.%$search%,phone_number.ilike.%$search%');
    }
    return await filtered.order('created_at', ascending: false).range(offset, offset + limit - 1);
  }

  Future<void> deleteUser(String id) async {
    await _supabase.from('profiles').delete().eq('id', id);
  }

  Future<List<Map<String, dynamic>>> getDrivers({
    int limit = 50,
    int offset = 0,
    String? search,
  }) async {
    final base = _supabase
        .from('drivers')
        .select('id, email, name, phone_number, vehicle_type, vehicle_number, state, created_at');
    var filtered = base;
    if (search != null && search.isNotEmpty) {
      filtered = filtered.or('email.ilike.%$search%,name.ilike.%$search%,phone_number.ilike.%$search%');
    }
    return await filtered.order('created_at', ascending: false).range(offset, offset + limit - 1);
  }

  Future<void> updateDriver({
    required String id,
    Map<String, dynamic> fields = const {},
  }) async {
    await _supabase.from('drivers').update(fields).eq('id', id);
  }

  Future<List<Map<String, dynamic>>> getOrders({
    int limit = 50,
    int offset = 0,
    String? status,
    String? search,
  }) async {
    final base = _supabase
        .from('orders')
        .select('id, user_id, driver_id, total_price, status, created_at');
    var filtered = status != null ? base.eq('status', status) : base;
    if (search != null && search.isNotEmpty) {
      // ندور على رقم الأوردر أو الـ user_id
      filtered = filtered.or('id.eq.$search,user_id.eq.$search');
    }
    final ordered = filtered.order('created_at', ascending: false).range(offset, offset + limit - 1);
    return await ordered;
  }

  Future<void> updateOrderStatus({
    required int id,
    required String status,
  }) async {
    await _supabase.from('orders').update({'status': status}).eq('id', id);
  }

  Future<List<Map<String, dynamic>>> getOrderItems(int orderId) async {
    return await _supabase
        .from('order_items')
        .select('id, product_id, quantity, products(name, price)')
        .eq('order_id', orderId);
  }

  // بنجيب بيانات الأوردر نفسه (رقم، عميل، مجموع، حالة)
  Future<Map<String, dynamic>?> getOrderById(int id) async {
    return await _supabase
        .from('orders')
        .select('id, user_id, driver_id, total_price, status, created_at, customer_name, phone_number, delivery_address')
        .eq('id', id)
        .maybeSingle();
  }

  // جلب كل المنتجات مع البحث
  Future<List<Map<String, dynamic>>> getProducts({
    int limit = 50,
    int offset = 0,
    String? search,
    String? category,
    String sortBy = 'created_at',
    bool ascending = false,
  }) async {
    final base = _supabase.from('products').select(
        'id, name, description, image, images, price, is_offer, new_price, qty, status, popular, is_top_seller, category, created_at');
    dynamic filtered = base;
    if (search != null && search.isNotEmpty) {
      filtered = filtered.or('name.ilike.%$search%,category.ilike.%$search%,description.ilike.%$search%');
    }
    if (category != null && category.isNotEmpty) {
      filtered = filtered.eq('category', category);
    }
    if (sortBy == 'price') {
      filtered = filtered.order('price', ascending: ascending);
    } else if (sortBy == 'name') {
      filtered = filtered.order('name', ascending: ascending);
    } else {
      filtered = filtered.order('created_at', ascending: ascending);
    }
    return await filtered.range(offset, offset + limit - 1);
  }

  Future<List<String>> getProductCategories() async {
    final data = await _supabase.from('products').select('category').not('category', 'is', null);
    final set = <String>{};
    for (final row in data) {
      final c = row['category']?.toString();
      if (c != null && c.isNotEmpty) set.add(c);
    }
    return set.toList()..sort();
  }

  // تبديل حالة المنتج (نشط/غير نشط) من الجدول مباشرة
  Future<void> toggleProductStatus(int id, int status) async {
    await _supabase.from('products').update({'status': status}).eq('id', id);
  }

  // إنشاء منتج جديد
  Future<Map<String, dynamic>> createProduct(Map<String, dynamic> data) async {
    final row = <String, dynamic>{
      'name': data['name'],
      'description': data['description'],
      'image': data['image'],
      'images': data['images'] ?? [],
      'price': data['price'],
      'is_offer': data['is_offer'] ?? false,
      'new_price': data['new_price'],
      'qty': data['qty'] ?? 0,
      'status': data['status'] ?? 1,
      'popular': data['popular'] ?? 0,
      'is_top_seller': data['is_top_seller'] ?? false,
      'category': data['category'],
    };
    return await _supabase.from('products').insert(row).select().single();
  }

  // تعديل منتج
  Future<void> updateProduct({required int id, required Map<String, dynamic> data}) async {
    await _supabase.from('products').update(data).eq('id', id);
  }

  // حذف منتج
  Future<void> deleteProduct(int id) async {
    await _supabase.from('products').delete().eq('id', id);
  }

  // حذف مجموعة منتجات
  Future<void> deleteProductsBulk(List<int> ids) async {
    await _supabase.from('products').delete().inFilter('id', ids);
  }

  // رفع صورة المنتج على الـ storage ويرجّع الرابط العام
  Future<String> uploadProductImage(Uint8List bytes, String fileName) async {
    final path = 'products/${DateTime.now().millisecondsSinceEpoch}_$fileName';
    await _supabase.storage.from('product-images').uploadBinary(path, bytes, fileOptions: const FileOptions(upsert: true));
    return _supabase.storage.from('product-images').getPublicUrl(path);
  }
}
