import 'package:supabase_flutter/supabase_flutter.dart';

class DriverHomeRemoteDataSource {
  SupabaseClient get _supabase => Supabase.instance.client;
  String? get _driverId => _supabase.auth.currentUser?.id;

  Future<List<Map<String, dynamic>>> getAvailableOrders() async {
    return await _supabase.from('orders').select('*, profiles(*)').neq('status', 'accepted');
  }

  Future<Map<String, dynamic>?> getDriverData() async {
    return await _supabase.from('drivers').select('*').eq('id', _driverId!).maybeSingle();
  }

  Future<Map<String, dynamic>?> updateDriverData({required String name, required String phoneNumber}) async {
    return await _supabase.from('drivers').update({
      'name': name, 'phone_number': phoneNumber,
    }).eq('id', _driverId!).select().maybeSingle();
  }

  Future<Map<String, dynamic>?> getOrderUser(int orderId) async {
    return await _supabase.from('orders').select('user_id').eq('id', orderId).maybeSingle();
  }

  Future<void> updateOrderStatus(int orderId, String status, String driverId) async {
    await _supabase.from('orders').update({
      'status': status, 'driver_id': driverId, 'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', orderId);
  }

  Future<List<Map<String, dynamic>>> getDriverOrders() async {
    return await _supabase.from('orders').select('*, profiles(*)').eq('driver_id', _driverId!);
  }

  Future<List<Map<String, dynamic>>> getStates() async {
    return await _supabase.from('states').select('*');
  }
}
