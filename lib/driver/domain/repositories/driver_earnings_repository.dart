import 'package:dartz/dartz.dart';
import 'package:ship_link/core/constants/Errors/failures.dart';

abstract class DriverEarningsRepository {
  Future<Either<Failure, double>> getTodayEarnings(String driverId);
  Future<Either<Failure, double>> getWeekEarnings(String driverId);
  Future<Either<Failure, double>> getAllTimeEarnings(String driverId);
  Future<Either<Failure, List<double>>> getDailyEarnings(String driverId, {int days = 7});
  Future<Either<Failure, Map<String, int>>> getOrderStatusCounts(String driverId);
  Future<Either<Failure, int>> getCompletedDeliveries(String driverId);
}
