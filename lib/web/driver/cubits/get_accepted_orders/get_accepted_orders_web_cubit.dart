import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/core/constants/Errors/failures.dart';
import 'package:ship_link/driver/data/models/getAcceptedOrders/get_accepted_orders.dart';
import 'package:ship_link/web/driver/data/driver_web_repository.dart';

part 'get_accepted_orders_web_state.dart';

class GetAcceptedOrdersWebCubit extends Cubit<GetAcceptedOrdersWebState> {
  final DriverWebRepositoryImpl _repository;
  GetAcceptedOrdersWebCubit(this._repository) : super(GetAcceptedOrdersInitial());

  Future<void> getAcceptedOrders() async {
    emit(GetAcceptedOrdersLoading());
    Either<Failure, GetAcceptOrder> result = await _repository.getAcceptedOrders();
    result.fold(
      (failure) => emit(GetAcceptedOrdersError(failure.errMessage)),
      (orders) => emit(GetAcceptedOrdersSuccess(orders)),
    );
  }
}
