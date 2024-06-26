import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ship_link/cubitDriver/get_orders/get_orders_cubit.dart';
import 'package:ship_link/data/models/acceptOrder/accept_order.dart';
import 'package:ship_link/data/services/DriverHomeServeices/driver_home_serveices.dart';

part 'accept_order_state.dart';

class AcceptOrderCubit extends Cubit<AcceptOrderState> {
  AcceptOrderCubit(this.driverHomeServeices) : super(AcceptOrderInitial());
  DriverHomeServeices driverHomeServeices;
  Future<void> acceptOrders({int? orderId}) async {
    emit(AcceptOrderLoading());
    var result = await driverHomeServeices.acceptOrders(orderId: orderId ?? 0);
    result.fold(
      (failure) {
        print(failure);
        if (failure.errMessage ==
            "type 'Null' is not a subtype of type 'AcceptOrder'") {
          emit(const AcceptOrderFailure('Selected order has been accepted'));
        } else {
          emit(AcceptOrderFailure(failure.errMessage));
        }
      },
      (success) {
        print(success);
        GetOrdersCubit(driverHomeServeices).getOrder();
        emit(AcceptOrderSuccess(success));
      },
    );
  }
}
