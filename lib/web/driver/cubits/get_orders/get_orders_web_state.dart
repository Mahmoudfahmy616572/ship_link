part of 'get_orders_web_cubit.dart';

sealed class GetOrdersWebState {}

final class GetOrdersInitial extends GetOrdersWebState {}
final class GetOrdersLoading extends GetOrdersWebState {}
final class GetOrdersSuccess extends GetOrdersWebState {
  final GetOrder getOrder;
  GetOrdersSuccess(this.getOrder);
}
final class GetOrdersError extends GetOrdersWebState {
  final String message;
  GetOrdersError(this.message);
}
