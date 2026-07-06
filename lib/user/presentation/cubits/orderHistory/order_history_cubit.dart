import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/user/presentation/cubits/orderHistory/order_history_state.dart';
import 'package:ship_link/user/domain/repositories/cart_repository.dart';

export 'package:ship_link/user/presentation/cubits/orderHistory/order_history_state.dart';

class OrderHistoryCubit extends Cubit<OrderHistoryState> {
  final CartRepository _service;
  OrderHistoryCubit(this._service) : super(OrderHistoryInitial());

  Future<void> loadOrders() async {
    if (!isClosed) emit(OrderHistoryLoading());
    final result = await _service.getOrderHistory();
    result.fold(
      (failure) { if (!isClosed) emit(OrderHistoryError(failure.errMessage)); },
      (orders) { if (!isClosed) emit(OrderHistoryLoaded(orders)); },
    );
  }
}
