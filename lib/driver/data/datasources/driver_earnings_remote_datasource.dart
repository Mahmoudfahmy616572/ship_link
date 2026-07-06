import 'package:supabase_flutter/supabase_flutter.dart';

class DriverEarningsRemoteDataSource {
  final SupabaseClient _supabase;

  DriverEarningsRemoteDataSource(this._supabase);

  Future<List<Map<String, dynamic>>> getDeliveredOrders(String driverId, {String? since}) async {
    var query = _supabase
        .from('orders')
        .select('total_price, created_at')
        .eq('driver_id', driverId)
        .eq('status', 'delivered');
    if (since != null) query = query.gte('created_at', since);
    return await query;
  }

  Future<List<Map<String, dynamic>>> getAllOrdersForStatus(String driverId) async {
    return await _supabase.from('orders').select('status').eq('driver_id', driverId);
  }
}
