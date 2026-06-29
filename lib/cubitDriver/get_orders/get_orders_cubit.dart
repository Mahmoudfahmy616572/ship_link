import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ship_link/data/services/DriverHomeServeices/driver_home_serveices.dart';
import 'package:ship_link/services/cache_service.dart';

import '../../data/models/get_order/get_order.dart';

part 'get_orders_state.dart';

class GetOrdersCubit extends Cubit<GetOrdersState> {
  GetOrdersCubit(this.driverHomeServeices) : super(GetOrdersInitial());
  final DriverHomeServeices driverHomeServeices;
  final _cache = CacheService();
  static const _cacheKey = 'cached_orders_v2';

  Future<void> getOrder() async {
    emit(GetOrdersLoading());
    var result = await driverHomeServeices.getOrders();
    result.fold(
      (failure) async {
        final cached = await _cache.get(_cacheKey);
        if (cached != null) {
          final order = GetOrder.fromJson(cached);
          emit(GetOrdersSuccess(order, isOffline: true));
        } else {
          emit(GetOrdersFailure(failure.errMessage));
        }
      },
      (order) async {
        await _cache.put(_cacheKey, order.toJson(), ttl: const Duration(hours: 1));
        emit(GetOrdersSuccess(order));
      },
    );
  }
}
