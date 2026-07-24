import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/core/constants/Errors/failures.dart';
import 'package:ship_link/driver/data/models/acceptOrder/accept_order.dart';
import 'package:ship_link/web/driver/data/driver_web_repository.dart';

part 'accept_order_web_state.dart';

class AcceptOrderWebCubit extends Cubit<AcceptOrderWebState> {
  final DriverWebRepositoryImpl _repository;
  AcceptOrderWebCubit(this._repository) : super(AcceptOrderInitial());

  Future<void> acceptOrders({required int orderId}) async {
    emit(AcceptOrderLoading());
    Either<Failure, AcceptOrder> result = await _repository.acceptOrders(orderId: orderId);
    result.fold(
      (failure) => emit(AcceptOrderError(failure.errMessage)),
      (order) => emit(AcceptOrderSuccess(order)),
    );
  }

  Future<void> markPickedUp({required int orderId}) async {
    emit(AcceptOrderLoading());
    Either<Failure, AcceptOrder> result = await _repository.markPickedUp(orderId: orderId);
    result.fold(
      (failure) => emit(AcceptOrderError(failure.errMessage)),
      (order) => emit(AcceptOrderSuccess(order)),
    );
  }

  Future<void> markShipped({required int orderId}) async {
    emit(AcceptOrderLoading());
    Either<Failure, AcceptOrder> result = await _repository.markShipped(orderId: orderId);
    result.fold(
      (failure) => emit(AcceptOrderError(failure.errMessage)),
      (order) => emit(AcceptOrderSuccess(order)),
    );
  }

  Future<void> markDelivered({required int orderId}) async {
    emit(AcceptOrderLoading());
    Either<Failure, AcceptOrder> result = await _repository.markDelivered(orderId: orderId);
    result.fold(
      (failure) => emit(AcceptOrderError(failure.errMessage)),
      (order) => emit(AcceptOrderSuccess(order)),
    );
  }

  Future<void> cancelOrder({required int orderId}) async {
    emit(AcceptOrderLoading());
    Either<Failure, AcceptOrder> result = await _repository.cancelOrder(orderId: orderId);
    result.fold(
      (failure) => emit(AcceptOrderError(failure.errMessage)),
      (order) => emit(AcceptOrderSuccess(order)),
    );
  }
}
