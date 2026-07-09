import 'package:dartz/dartz.dart';
import 'package:ship_link/core/constants/Errors/failures.dart';

abstract class PaymentMethodsRepository {
  Future<Either<Failure, List<Map<String, dynamic>>>> getAll();
  Future<Either<Failure, void>> add({
    required String paymobToken,
    required String lastFour,
    String cardBrand = '',
    bool isDefault = false,
  });
  Future<Either<Failure, void>> setDefault(String id);
  Future<Either<Failure, void>> delete(String id);
}
