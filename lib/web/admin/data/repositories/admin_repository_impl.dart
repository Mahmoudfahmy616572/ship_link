import 'package:dartz/dartz.dart';
import 'package:ship_link/core/constants/Errors/failures.dart';
import 'package:ship_link/web/admin/data/datasources/admin_remote_datasource.dart';
import 'package:ship_link/web/admin/domain/repositories/admin_repository.dart';

class AdminRepositoryImpl extends AdminRepository {
  AdminRepositoryImpl();

  final _dataSource = AdminRemoteDataSource();

  @override
  Future<Either<Failure, Map<String, dynamic>>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final admin = await _dataSource.signIn(email: email, password: password);
      return right(admin);
    } catch (e) {
      return left(ServerFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _dataSource.signOut();
      return right(null);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>?>> checkSession() async {
    try {
      final admin = await _dataSource.checkSession();
      return right(admin);
    } catch (e) {
      return left(ServerFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getDashboardStats({String period = 'all'}) async {
    try {
      final stats = await _dataSource.getDashboardStats(period: period);
      return right(stats);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getUsers({int limit = 50, int offset = 0}) async {
    try {
      final data = await _dataSource.getUsers(limit: limit, offset: offset);
      return right(data);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getDrivers({int limit = 50, int offset = 0}) async {
    try {
      final data = await _dataSource.getDrivers(limit: limit, offset: offset);
      return right(data);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateDriver({required String id, Map<String, dynamic> fields = const {}}) async {
    try {
      await _dataSource.updateDriver(id: id, fields: fields);
      return right(null);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getOrders({int limit = 50, int offset = 0, String? status}) async {
    try {
      final data = await _dataSource.getOrders(limit: limit, offset: offset, status: status);
      return right(data);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateOrderStatus({required int id, required String status}) async {
    try {
      await _dataSource.updateOrderStatus(id: id, status: status);
      return right(null);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getOrderItems(int orderId) async {
    try {
      final data = await _dataSource.getOrderItems(orderId);
      return right(data);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>?>> getOrderById(int id) async {
    try {
      final data = await _dataSource.getOrderById(id);
      return right(data);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }
}
