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

  Future<Map<String, dynamic>> getDashboardStats() async {
    // بنجيب عدد الصفوف لكل جدول (من غير limit عشان نعرف العدد الكلي)
    final r1 = await _supabase.from('profiles').select('id');
    final r2 = await _supabase.from('drivers').select('id');
    final r3 = await _supabase.from('orders').select('id');
    final r4 = await _supabase.from('products').select('id');
    final users = r1.length;
    final drivers = r2.length;
    final orders = r3.length;
    final products = r4.length;

    final ordersData = await _supabase
        .from('orders')
        .select('total_price, status')
        .eq('status', 'delivered');
    double revenue = 0;
    for (final o in ordersData) {
      revenue += (o['total_price'] is num ? (o['total_price'] as num).toDouble() : 0);
    }

    final statusData = await _supabase
        .from('orders')
        .select('status');
    final Map<String, int> statusCounts = {};
    for (final o in statusData) {
      final s = o['status'] as String? ?? 'unknown';
      statusCounts[s] = (statusCounts[s] ?? 0) + 1;
    }

    return {
      'users': users,
      'drivers': drivers,
      'orders': orders,
      'products': products,
      'revenue': revenue,
      'statusCounts': statusCounts,
    };
  }

  Future<List<Map<String, dynamic>>> getUsers({
    int limit = 50,
    int offset = 0,
  }) async {
    return await _supabase
        .from('profiles')
        .select('id, email, name, phone_number, role, created_at')
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);
  }

  Future<List<Map<String, dynamic>>> getDrivers({
    int limit = 50,
    int offset = 0,
  }) async {
    return await _supabase
        .from('drivers')
        .select('id, email, name, phone_number, vehicle_type, vehicle_number, state, created_at')
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);
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
  }) async {
    return await _supabase
        .from('orders')
        .select('id, user_id, driver_id, total_price, status, created_at')
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);
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
}
