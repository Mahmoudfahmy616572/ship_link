import 'package:dartz/dartz.dart';
import 'package:ship_link/core/constants/Errors/failures.dart';

abstract class AdminRepository {
  Future<Either<Failure, Map<String, dynamic>>> signIn({
    required String email,
    required String password,
  });
  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, Map<String, dynamic>?>> checkSession();
  Future<Either<Failure, Map<String, dynamic>>> getDashboardStats();
  Future<Either<Failure, List<Map<String, dynamic>>>> getUsers({int limit, int offset});
  Future<Either<Failure, List<Map<String, dynamic>>>> getDrivers({int limit, int offset});
  Future<Either<Failure, void>> updateDriver({required String id, Map<String, dynamic> fields});
  Future<Either<Failure, List<Map<String, dynamic>>>> getOrders({int limit, int offset});
  Future<Either<Failure, void>> updateOrderStatus({required int id, required String status});
  Future<Either<Failure, List<Map<String, dynamic>>>> getOrderItems(int orderId);
}
