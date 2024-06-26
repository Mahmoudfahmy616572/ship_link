import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ship_link/data/models/getAcceptedOrders/get_accepted_orders.dart';

import '../../data/services/DriverHomeServeices/driver_home_serveices.dart';

part 'get_accepted_order_state.dart';

class GetAcceptedOrderCubit extends Cubit<GetAcceptedOrderState> {
  GetAcceptedOrderCubit(this.driverHomeServeices)
      : super(GetAcceptedOrderInitial());
  final DriverHomeServeices driverHomeServeices;

  Future<void> getAcceptedOrder() async {
    emit(GetAcceptedOrderLoading());
    var result = await driverHomeServeices.getAcceptedOrders();
    result.fold(
      (failure) {
        emit(GetAcceptedOrderFailure(failure.errMessage));
      },
      (order) {
        emit(GetAcceptedOrderSuccess(order));
      },
    );
  }
}
