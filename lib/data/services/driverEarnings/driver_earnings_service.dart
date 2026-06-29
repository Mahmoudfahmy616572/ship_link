import 'package:supabase_flutter/supabase_flutter.dart';

class DriverEarningsService {
  final SupabaseClient _supabase;

  DriverEarningsService(this._supabase);

  Future<double> getTodayEarnings(String driverId) async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final data = await _supabase
        .from('orders')
        .select('total_price')
        .eq('driver_id', driverId)
        .eq('status', 'delivered')
        .gte('created_at', startOfDay.toIso8601String());
    double total = 0;
    for (final row in data) {
      total += ((row['total_price'] as num?)?.toDouble() ?? 0);
    }
    return total;
  }

  Future<double> getWeekEarnings(String driverId) async {
    final today = DateTime.now();
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final startOfDay = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    final data = await _supabase
        .from('orders')
        .select('total_price')
        .eq('driver_id', driverId)
        .eq('status', 'delivered')
        .gte('created_at', startOfDay.toIso8601String());
    double total = 0;
    for (final row in data) {
      total += ((row['total_price'] as num?)?.toDouble() ?? 0);
    }
    return total;
  }

  Future<double> getAllTimeEarnings(String driverId) async {
    final data = await _supabase
        .from('orders')
        .select('total_price')
        .eq('driver_id', driverId)
        .eq('status', 'delivered');
    double total = 0;
    for (final row in data) {
      total += ((row['total_price'] as num?)?.toDouble() ?? 0);
    }
    return total;
  }

  Future<List<double>> getDailyEarnings(String driverId, {int days = 7}) async {
    final today = DateTime.now();
    final start = today.subtract(Duration(days: days - 1));
    final startOfDay = DateTime(start.year, start.month, start.day);
    final data = await _supabase
        .from('orders')
        .select('total_price, created_at')
        .eq('driver_id', driverId)
        .eq('status', 'delivered')
        .gte('created_at', startOfDay.toIso8601String());
    final daily = List.filled(days, 0.0);
    for (final row in data) {
      final createdAt = row['created_at'] as String?;
      if (createdAt == null) continue;
      final day = DateTime.parse(createdAt);
      final diff = day.difference(startOfDay).inDays;
      if (diff >= 0 && diff < days) {
        daily[diff] += ((row['total_price'] as num?)?.toDouble() ?? 0);
      }
    }
    return daily;
  }

  Future<Map<String, int>> getOrderStatusCounts(String driverId) async {
    final data = await _supabase
        .from('orders')
        .select('status')
        .eq('driver_id', driverId);
    final counts = <String, int>{};
    for (final row in data) {
      final status = row['status'] as String? ?? 'unknown';
      counts[status] = (counts[status] ?? 0) + 1;
    }
    return counts;
  }

  Future<int> getCompletedDeliveries(String driverId) async {
    final data = await _supabase
        .from('orders')
        .select('id')
        .eq('driver_id', driverId)
        .eq('status', 'delivered');
    return data.length;
  }
}
