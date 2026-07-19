import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ship_link/core/constants/Errors/failures.dart';
import 'package:ship_link/web/admin/domain/models/admin_models.dart';
import 'package:ship_link/web/admin/domain/repositories/admin_repository.dart';
import 'package:ship_link/web/admin/presentation/cubits/products/admin_products_cubit.dart';
import 'package:ship_link/web/admin/presentation/cubits/products/admin_products_state.dart';

// موك بسيط للريبوزيتوري عشان نختبر الكيوبت من غير شبكة
class FakeAdminRepository implements AdminRepository {
  List<AdminProduct> productsToReturn = [AdminProduct(id: 1, name: 'Test', price: 10)];
  String? lastSearch;
  bool failGet = false;
  bool failCreate = false;
  Map<String, dynamic>? createdData;
  int? deletedId;
  int? updatedId;

  @override
  Future<Either<Failure, List<AdminProduct>>> getProducts({int limit = 20, int offset = 0, String? search}) async {
    lastSearch = search;
    if (failGet) return left(ServerFailure('boom'));
    return right(productsToReturn);
  }

  @override
  Future<Either<Failure, AdminProduct>> createProduct(Map<String, dynamic> data) async {
    createdData = data;
    if (failCreate) return left(ServerFailure('create failed'));
    return right(AdminProduct.fromMap(data..['id'] = 99));
  }

  @override
  Future<Either<Failure, void>> updateProduct({required int id, required Map<String, dynamic> data}) async {
    updatedId = id;
    return right(null);
  }

  @override
  Future<Either<Failure, void>> deleteProduct(int id) async {
    deletedId = id;
    return right(null);
  }

  // باقي الدوال مش محتاجين للاختبار ده
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('AdminProductsCubit', () {
    test('loadProducts emits loading then loaded with products', () async {
      final repo = FakeAdminRepository();
      final cubit = AdminProductsCubit(repo);
      final states = <AdminProductsState>[];

      cubit.stream.listen(states.add);
      await cubit.loadProducts();
      await Future.delayed(Duration.zero);

      expect(states.any((s) => s is AdminProductsLoading), isTrue);
      expect(states.last, isA<AdminProductsLoaded>());
      expect((states.last as AdminProductsLoaded).products.length, 1);
      await cubit.close();
      await Future.delayed(Duration.zero);
    });

    test('loadProducts with search passes search to repo', () async {
      final repo = FakeAdminRepository();
      final cubit = AdminProductsCubit(repo);
      await cubit.loadProducts(search: 'shirt');
      await Future.delayed(Duration.zero);
      expect(repo.lastSearch, 'shirt');
      await cubit.close();
      await Future.delayed(Duration.zero);
    });

    test('loadProducts emits error on failure', () async {
      final repo = FakeAdminRepository()..failGet = true;
      final cubit = AdminProductsCubit(repo);
      final states = <AdminProductsState>[];
      cubit.stream.listen(states.add);
      await cubit.loadProducts();
      await Future.delayed(Duration.zero);
      expect(states.last, isA<AdminProductsError>());
      await cubit.close();
      await Future.delayed(Duration.zero);
    });

    test('createProduct emits save success', () async {
      final repo = FakeAdminRepository();
      final cubit = AdminProductsCubit(repo);
      final states = <AdminProductsState>[];
      cubit.stream.listen(states.add);
      await cubit.createProduct({'name': 'New', 'price': 5});
      await Future.delayed(Duration.zero);
      expect(repo.createdData?['name'], 'New');
      expect(states.last, isA<AdminProductSaveSuccess>());
      expect((states.last as AdminProductSaveSuccess).id, 99);
      await cubit.close();
      await Future.delayed(Duration.zero);
    });

    test('deleteProduct emits delete success with id', () async {
      final repo = FakeAdminRepository();
      final cubit = AdminProductsCubit(repo);
      final states = <AdminProductsState>[];
      cubit.stream.listen(states.add);
      await cubit.deleteProduct(42);
      await Future.delayed(Duration.zero);
      expect(repo.deletedId, 42);
      expect(states.last, isA<AdminProductDeleteSuccess>());
      expect((states.last as AdminProductDeleteSuccess).id, 42);
      await cubit.close();
      await Future.delayed(Duration.zero);
    });
  });
}
