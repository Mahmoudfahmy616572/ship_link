import 'package:dartz/dartz.dart';
import 'package:ship_link/core/constants/Errors/failures.dart';
import 'package:ship_link/user/domain/repositories/payment_methods_repository.dart';
import 'package:ship_link/user/data/datasources/payment_methods_remote_datasource.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentMethodsRepositoryImpl extends PaymentMethodsRepository {
  final _dataSource = PaymentMethodsRemoteDataSource();

  String? get _userId => Supabase.instance.client.auth.currentUser?.id;

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getAll() async {
    try {
      final uid = _userId;
      if (uid == null) return left(ServerFailure('Not authenticated'));
      final data = await _dataSource.getAll(uid);
      return right(data);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> add({
    required String paymobToken,
    required String lastFour,
    String cardBrand = '',
    bool isDefault = false,
  }) async {
    try {
      final uid = _userId;
      if (uid == null) return left(ServerFailure('Not authenticated'));
      if (isDefault) await _dataSource.clearDefaults(uid);
      await _dataSource.insert({
        'user_id': uid,
        'paymob_token': paymobToken,
        'last_four': lastFour,
        'card_brand': cardBrand,
        'is_default': isDefault,
      });
      return right(null);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> setDefault(String id) async {
    try {
      final uid = _userId;
      if (uid == null) return left(ServerFailure('Not authenticated'));
      await _dataSource.clearDefaults(uid);
      await _dataSource.setDefault(id);
      return right(null);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> delete(String id) async {
    try {
      await _dataSource.delete(id);
      return right(null);
    } catch (e) {
      return left(ServerFailure(e.toString()));
    }
  }
}
