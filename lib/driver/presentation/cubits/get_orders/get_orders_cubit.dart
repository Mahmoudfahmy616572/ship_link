import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ship_link/driver/domain/repositories/driver_home_repository.dart';
import 'package:ship_link/core/services/cache_service.dart';

import 'package:ship_link/driver/data/models/get_order/get_order.dart';

part 'get_orders_state.dart';

class GetOrdersCubit extends Cubit<GetOrdersState> {
  GetOrdersCubit(this.driverHomeServeices) : super(GetOrdersInitial());
  final DriverHomeRepository driverHomeServeices;
  final _cache = CacheService();
  static const _cacheKey = 'cached_orders_v2';

  Future<void> getOrder() async {
    emit(GetOrdersLoading());
    var result = await driverHomeServeices.getOrders();
    if (isClosed) return;
    result.fold(
      (failure) async {
        final cached = await _cache.get(_cacheKey);
        if (isClosed) return;
        if (cached != null) {
          final order = GetOrder.fromJson(cached);
          emit(GetOrdersSuccess(order, isOffline: true));
        } else {
          emit(GetOrdersFailure(failure.errMessage));
        }
      },
      (order) async {
        await _cache.put(_cacheKey, order.toJson(), ttl: const Duration(hours: 1));
        if (isClosed) return;
        emit(GetOrdersSuccess(order));
      },
    );
  }
}
