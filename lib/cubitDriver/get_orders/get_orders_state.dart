part of 'get_orders_cubit.dart';

sealed class GetOrdersState extends Equatable {
  const GetOrdersState();

  @override
  List<Object> get props => [];
}

final class GetOrdersInitial extends GetOrdersState {}

final class GetOrdersLoading extends GetOrdersState {}

final class GetOrdersSuccess extends GetOrdersState {
  final GetOrder getOrder;
  const GetOrdersSuccess(this.getOrder);
}

final class GetOrdersFailure extends GetOrdersState {
  final String errMessage;
  const GetOrdersFailure(this.errMessage);
}
