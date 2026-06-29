import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
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
        if (failure.errMessage ==
            "type 'Null' is not a subtype of type 'AcceptOrder'") {
          emit(const AcceptOrderFailure('Selected order has been accepted'));
        } else {
          emit(AcceptOrderFailure(failure.errMessage));
        }
      },
      (success) {
        emit(AcceptOrderSuccess(success));
      },
    );
  }

  Future<void> markPickedUp({required int orderId}) async {
    emit(AcceptOrderLoading());
    var result = await driverHomeServeices.markPickedUp(orderId: orderId);
    result.fold(
      (failure) {
        print('markPickedUp error: ${failure.errMessage}');
        emit(AcceptOrderFailure(failure.errMessage));
      },
      (success) => emit(AcceptOrderSuccess(success)),
    );
  }

  Future<void> markShipped({required int orderId}) async {
    emit(AcceptOrderLoading());
    var result = await driverHomeServeices.markShipped(orderId: orderId);
    result.fold(
      (failure) {
        print('markShipped error: ${failure.errMessage}');
        emit(AcceptOrderFailure(failure.errMessage));
      },
      (success) => emit(AcceptOrderSuccess(success)),
    );
  }

  Future<void> markDelivered({required int orderId}) async {
    emit(AcceptOrderLoading());
    var result = await driverHomeServeices.markDelivered(orderId: orderId);
    result.fold(
      (failure) {
        print('markDelivered error: ${failure.errMessage}');
        emit(AcceptOrderFailure(failure.errMessage));
      },
      (success) => emit(AcceptOrderSuccess(success)),
    );
  }

  Future<void> cancelOrder({required int orderId}) async {
    emit(AcceptOrderLoading());
    var result = await driverHomeServeices.cancelOrder(orderId: orderId);
    result.fold(
      (failure) {
        print('cancelOrder error: ${failure.errMessage}');
        emit(AcceptOrderFailure(failure.errMessage));
      },
      (success) => emit(AcceptOrderSuccess(success)),
    );
  }
}
