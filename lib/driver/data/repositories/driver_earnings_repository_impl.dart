import 'package:dartz/dartz.dart';
import 'package:ship_link/core/constants/Errors/failures.dart';
import 'package:ship_link/driver/domain/repositories/driver_earnings_repository.dart';
import 'package:ship_link/driver/data/datasources/driver_earnings_remote_datasource.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DriverEarningsRepositoryImpl extends DriverEarningsRepository {
  final _dataSource = DriverEarningsRemoteDataSource(Supabase.instance.client);

  @override
  Future<Either<Failure, double>> getTodayEarnings(String driverId) async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final data = await _dataSource.getDeliveredOrders(driverId, since: startOfDay.toIso8601String());
      double total = 0;
      for (final row in data) total += ((row['total_price'] as num?)?.toDouble() ?? 0);
      return right(total);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, double>> getWeekEarnings(String driverId) async {
    try {
      final today = DateTime.now();
      final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
      final startOfDay = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
      final data = await _dataSource.getDeliveredOrders(driverId, since: startOfDay.toIso8601String());
      double total = 0;
      for (final row in data) total += ((row['total_price'] as num?)?.toDouble() ?? 0);
      return right(total);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, double>> getAllTimeEarnings(String driverId) async {
    try {
      final data = await _dataSource.getDeliveredOrders(driverId);
      double total = 0;
      for (final row in data) total += ((row['total_price'] as num?)?.toDouble() ?? 0);
      return right(total);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<double>>> getDailyEarnings(String driverId, {int days = 7}) async {
    try {
      final today = DateTime.now();
      final start = today.subtract(Duration(days: days - 1));
      final startOfDay = DateTime(start.year, start.month, start.day);
      final data = await _dataSource.getDeliveredOrders(driverId, since: startOfDay.toIso8601String());
      final daily = List.filled(days, 0.0);
      for (final row in data) {
        final createdAt = row['created_at'] as String?;
        if (createdAt == null) continue;
        final day = DateTime.parse(createdAt);
        final diff = day.difference(startOfDay).inDays;
        if (diff >= 0 && diff < days) daily[diff] += ((row['total_price'] as num?)?.toDouble() ?? 0);
      }
      return right(daily);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, int>>> getOrderStatusCounts(String driverId) async {
    try {
      final data = await _dataSource.getAllOrdersForStatus(driverId);
      final counts = <String, int>{};
      for (final row in data) {
        final status = row['status'] as String? ?? 'unknown';
        counts[status] = (counts[status] ?? 0) + 1;
      }
      return right(counts);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getCompletedDeliveries(String driverId) async {
    try {
      final data = await _dataSource.getDeliveredOrders(driverId);
      return right(data.length);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }
}
