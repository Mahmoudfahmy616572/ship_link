part of 'get_accepted_order_cubit.dart';

sealed class GetAcceptedOrderState extends Equatable {
  const GetAcceptedOrderState();

  @override
  List<Object> get props => [];
}

final class GetAcceptedOrderInitial extends GetAcceptedOrderState {}

final class GetAcceptedOrderLoading extends GetAcceptedOrderState {}

final class GetAcceptedOrderFailure extends GetAcceptedOrderState {
  final String errMessage;
  const GetAcceptedOrderFailure(this.errMessage);
}

final class GetAcceptedOrderSuccess extends GetAcceptedOrderState {
  final GetAcceptOrder getAcceptedOrder;
  const GetAcceptedOrderSuccess(this.getAcceptedOrder);
}
