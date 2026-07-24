import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/core/constants/Errors/failures.dart';
import 'package:ship_link/driver/data/models/get_order/get_order.dart';
import 'package:ship_link/web/driver/data/driver_web_repository.dart';

part 'get_orders_web_state.dart';

class GetOrdersWebCubit extends Cubit<GetOrdersWebState> {
  final DriverWebRepositoryImpl _repository;
  GetOrdersWebCubit(this._repository) : super(GetOrdersInitial());

  Future<void> getOrders() async {
    emit(GetOrdersLoading());
    Either<Failure, GetOrder> result = await _repository.getOrders();
    result.fold(
      (failure) => emit(GetOrdersError(failure.errMessage)),
      (orders) => emit(GetOrdersSuccess(orders)),
    );
  }
}
