import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/web/admin/domain/repositories/admin_repository.dart';
import 'package:ship_link/web/admin/presentation/cubits/orders/admin_orders_state.dart';

export 'package:ship_link/web/admin/presentation/cubits/orders/admin_orders_state.dart';

class AdminOrdersCubit extends Cubit<AdminOrdersState> {
  AdminOrdersCubit(this._repository) : super(AdminOrdersInitial());

  final AdminRepository _repository;

  static AdminOrdersCubit get(context) => BlocProvider.of<AdminOrdersCubit>(context);

  Future<void> loadOrders({int limit = 20, int offset = 0, String? status, String? search, bool append = false}) async {
    if (!append) {
      if (!isClosed) emit(AdminOrdersLoading());
    }
    final result = await _repository.getOrders(limit: limit, offset: offset, status: status, search: search);
    result.fold(
      (failure) {
        if (!isClosed) emit(AdminOrdersError(failure.errMessage));
      },
      (orders) {
        if (!isClosed) {
          final current = append && state is AdminOrdersLoaded ? (state as AdminOrdersLoaded).orders : <Map<String, dynamic>>[];
          final merged = [...current, ...orders];
          emit(AdminOrdersLoaded(merged, status: status, search: search, hasMore: orders.length >= limit));
        }
      },
    );
  }

  Future<void> loadMoreOrders({String? status, String? search}) async {
    if (state is! AdminOrdersLoaded) return;
    final loaded = state as AdminOrdersLoaded;
    if (!loaded.hasMore) return;
    await loadOrders(offset: loaded.orders.length, status: status, search: search, append: true);
  }

  Future<void> updateStatus({required int id, required String status}) async {
    final result = await _repository.updateOrderStatus(id: id, status: status);
    result.fold(
      (failure) {
        if (!isClosed) emit(AdminOrdersError(failure.errMessage));
      },
      (_) {
        if (!isClosed) emit(AdminOrderUpdateSuccess(id));
      },
    );
  }

  Future<void> loadOrderItems(int orderId) async {
    if (!isClosed) emit(AdminOrdersLoading());
    final itemsResult = await _repository.getOrderItems(orderId);
    final orderResult = await _repository.getOrderById(orderId);
    Map<String, dynamic>? order;
    orderResult.fold(
      (_) => order = null,
      (o) => order = o,
    );
    itemsResult.fold(
      (failure) {
        if (!isClosed) emit(AdminOrdersError(failure.errMessage));
      },
      (items) {
        if (!isClosed) emit(AdminOrderDetailLoaded(orderId, items, order: order));
      },
    );
  }
}
