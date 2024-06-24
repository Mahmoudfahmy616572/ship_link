import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ship_link/data/services/DriverHomeServeices/driver_home_serveices.dart';

import '../../data/models/get_order/get_order.dart';

part 'get_orders_state.dart';

class GetOrdersCubit extends Cubit<GetOrdersState> {
  GetOrdersCubit(this.driverHomeServeices) : super(GetOrdersInitial());
  final DriverHomeServeices driverHomeServeices;
  Future<void> getOrder() async {
    emit(GetOrdersLoading());
    var result = await driverHomeServeices.getOrders();
    result.fold(
      (failure) {
        emit(GetOrdersFailure(failure.errMessage));
      },
      (order) {
        emit(GetOrdersSuccess(order));
      },
    );
  }
}
