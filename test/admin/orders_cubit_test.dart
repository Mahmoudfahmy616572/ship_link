import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ship_link/core/constants/Errors/failures.dart';
import 'package:ship_link/web/admin/domain/repositories/admin_repository.dart';
import 'package:ship_link/web/admin/presentation/cubits/orders/admin_orders_cubit.dart';
import 'package:ship_link/web/admin/presentation/cubits/orders/admin_orders_state.dart';

class FakeOrdersRepository implements AdminRepository {
  List<Map<String, dynamic>> orders = List.generate(25, (i) => {'id': i + 1, 'status': 'pending'});
  bool failGet = false;
  int? updatedId;
  String? updatedStatus;

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getOrders({int limit = 20, int offset = 0, String? status, String? search}) async {
    if (failGet) return left(ServerFailure('boom'));
    final end = (offset + limit).clamp(0, orders.length);
    return right(orders.sublist(offset, end));
  }

  @override
  Future<Either<Failure, void>> updateOrderStatus({required int id, required String status}) async {
    updatedId = id;
    updatedStatus = status;
    return right(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('AdminOrdersCubit', () {
    test('loadOrders emits loaded with first page and hasMore true', () async {
      final repo = FakeOrdersRepository();
      final cubit = AdminOrdersCubit(repo);
      final states = <AdminOrdersState>[];
      cubit.stream.listen(states.add);
      await cubit.loadOrders();
      await Future.delayed(Duration.zero);
      final loaded = states.last as AdminOrdersLoaded;
      expect(loaded.orders.length, 20);
      expect(loaded.hasMore, isTrue);
      await cubit.close();
      await Future.delayed(Duration.zero);
    });

    test('loadMoreOrders appends and reduces hasMore', () async {
      final repo = FakeOrdersRepository();
      final cubit = AdminOrdersCubit(repo);
      await cubit.loadOrders();
      await Future.delayed(Duration.zero);
      final states = <AdminOrdersState>[];
      cubit.stream.listen(states.add);
      await cubit.loadMoreOrders();
      await Future.delayed(Duration.zero);
      final loaded = states.last as AdminOrdersLoaded;
      expect(loaded.orders.length, 25);
      expect(loaded.hasMore, isFalse);
      await cubit.close();
      await Future.delayed(Duration.zero);
    });

    test('updateStatus emits success', () async {
      final repo = FakeOrdersRepository();
      final cubit = AdminOrdersCubit(repo);
      final states = <AdminOrdersState>[];
      cubit.stream.listen(states.add);
      await cubit.updateStatus(id: 3, status: 'delivered');
      await Future.delayed(Duration.zero);
      expect(repo.updatedId, 3);
      expect(repo.updatedStatus, 'delivered');
      expect(states.last, isA<AdminOrderUpdateSuccess>());
      await cubit.close();
      await Future.delayed(Duration.zero);
    });

    test('loadOrders emits error on failure', () async {
      final repo = FakeOrdersRepository()..failGet = true;
      final cubit = AdminOrdersCubit(repo);
      final states = <AdminOrdersState>[];
      cubit.stream.listen(states.add);
      await cubit.loadOrders();
      await Future.delayed(Duration.zero);
      expect(states.last, isA<AdminOrdersError>());
      await cubit.close();
      await Future.delayed(Duration.zero);
    });
  });
}
