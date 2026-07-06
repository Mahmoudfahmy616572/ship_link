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
  final bool isOffline;
  const GetOrdersSuccess(this.getOrder, {this.isOffline = false});
}

final class GetOrdersFailure extends GetOrdersState {
  final String errMessage;
  const GetOrdersFailure(this.errMessage);
}
