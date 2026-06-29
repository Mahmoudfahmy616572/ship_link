import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ship_link/data/models/getAcceptedOrders/get_accepted_orders.dart';
import 'package:ship_link/services/cache_service.dart';

import '../../data/services/DriverHomeServeices/driver_home_serveices.dart';

part 'get_accepted_order_state.dart';

class GetAcceptedOrderCubit extends Cubit<GetAcceptedOrderState> {
  GetAcceptedOrderCubit(this.driverHomeServeices)
      : super(GetAcceptedOrderInitial());
  final DriverHomeServeices driverHomeServeices;
  final _cache = CacheService();
  static const _cacheKey = 'cached_accepted_orders_v2';

  Future<void> getAcceptedOrder() async {
    emit(GetAcceptedOrderLoading());
    var result = await driverHomeServeices.getAcceptedOrders();
    result.fold(
      (failure) async {
        final cached = await _cache.get(_cacheKey);
        if (cached != null) {
          final order = GetAcceptOrder.fromJson(cached);
          emit(GetAcceptedOrderSuccess(order, isOffline: true));
        } else {
          emit(GetAcceptedOrderFailure(failure.errMessage));
        }
      },
      (order) async {
        await _cache.put(_cacheKey, order.toJson(), ttl: const Duration(hours: 1));
        emit(GetAcceptedOrderSuccess(order));
      },
    );
  }
}
