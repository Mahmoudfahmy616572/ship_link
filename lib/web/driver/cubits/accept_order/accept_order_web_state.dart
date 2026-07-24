part of 'accept_order_web_cubit.dart';

sealed class AcceptOrderWebState {}

final class AcceptOrderInitial extends AcceptOrderWebState {}
final class AcceptOrderLoading extends AcceptOrderWebState {}
final class AcceptOrderSuccess extends AcceptOrderWebState {
  final AcceptOrder acceptOrder;
  AcceptOrderSuccess(this.acceptOrder);
}
final class AcceptOrderError extends AcceptOrderWebState {
  final String message;
  AcceptOrderError(this.message);
}
