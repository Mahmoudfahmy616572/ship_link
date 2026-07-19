import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import 'package:ship_link/core/constants/Errors/failures.dart';
import 'package:ship_link/web/admin/data/datasources/admin_remote_datasource.dart';
import 'package:ship_link/web/admin/domain/repositories/admin_repository.dart';
import 'package:ship_link/web/admin/presentation/utils/admin_list_cache.dart';
import 'package:ship_link/web/admin/domain/models/admin_models.dart';

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
  Future<Either<Failure, List<Map<String, dynamic>>>> getUsers({int limit = 50, int offset = 0, String? search}) async {
    try {
      final cacheKey = 'users';
      if (search == null && offset == 0) {
        final cached = AdminListCache.get(cacheKey);
        if (cached != null) return right(cached);
      }
      final data = await _dataSource.getUsers(limit: limit, offset: offset, search: search);
      if (search == null && offset == 0) AdminListCache.set(cacheKey, data);
      return right(data);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getDrivers({int limit = 50, int offset = 0, String? search}) async {
    try {
      final cacheKey = 'drivers';
      if (search == null && offset == 0) {
        final cached = AdminListCache.get(cacheKey);
        if (cached != null) return right(cached);
      }
      final data = await _dataSource.getDrivers(limit: limit, offset: offset, search: search);
      if (search == null && offset == 0) AdminListCache.set(cacheKey, data);
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
  Future<Either<Failure, List<Map<String, dynamic>>>> getOrders({int limit = 50, int offset = 0, String? status, String? search}) async {
    try {
      final cacheKey = 'orders_$status';
      if (search == null && offset == 0) {
        final cached = AdminListCache.get(cacheKey);
        if (cached != null) return right(cached);
      }
      final data = await _dataSource.getOrders(limit: limit, offset: offset, status: status, search: search);
      if (search == null && offset == 0) AdminListCache.set(cacheKey, data);
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

  @override
  Future<Either<Failure, List<AdminProduct>>> getProducts({int limit = 50, int offset = 0, String? search}) async {
    try {
      // كاش للتحميل الأولي بدون بحث/صفحات
      final cacheKey = 'products';
      if (search == null && offset == 0) {
        final cached = AdminListCache.get(cacheKey);
        if (cached != null) return right(cached.cast<AdminProduct>());
      }
      final data = await _dataSource.getProducts(limit: limit, offset: offset, search: search);
      final models = data.map((m) => AdminProduct.fromMap(m)).toList();
      if (search == null && offset == 0) AdminListCache.set(cacheKey, data);
      return right(models);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AdminProduct>> createProduct(Map<String, dynamic> data) async {
    try {
      final created = await _dataSource.createProduct(data);
      return right(AdminProduct.fromMap(created));
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateProduct({required int id, required Map<String, dynamic> data}) async {
    try {
      await _dataSource.updateProduct(id: id, data: data);
      return right(null);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProduct(int id) async {
    try {
      await _dataSource.deleteProduct(id);
      return right(null);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadProductImage(Uint8List bytes, String fileName) async {
    try {
      final url = await _dataSource.uploadProductImage(bytes, fileName);
      return right(url);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }
}
