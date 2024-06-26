part of 'accept_order_cubit.dart';

sealed class AcceptOrderState extends Equatable {
  const AcceptOrderState();

  @override
  List<Object> get props => [];
}

final class AcceptOrderInitial extends AcceptOrderState {}

final class AcceptOrderLoading extends AcceptOrderState {}

final class AcceptOrderSuccess extends AcceptOrderState {
  final AcceptOrder acceptOrder;
  const AcceptOrderSuccess(this.acceptOrder);
}

final class AcceptOrderFailure extends AcceptOrderState {
  final String errMessage;
  const AcceptOrderFailure(this.errMessage);
}
