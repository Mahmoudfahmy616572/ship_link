part of 'get_accepted_orders_web_cubit.dart';

sealed class GetAcceptedOrdersWebState {}

final class GetAcceptedOrdersInitial extends GetAcceptedOrdersWebState {}
final class GetAcceptedOrdersLoading extends GetAcceptedOrdersWebState {}
final class GetAcceptedOrdersSuccess extends GetAcceptedOrdersWebState {
  final GetAcceptOrder getOrder;
  GetAcceptedOrdersSuccess(this.getOrder);
}
final class GetAcceptedOrdersError extends GetAcceptedOrdersWebState {
  final String message;
  GetAcceptedOrdersError(this.message);
}
