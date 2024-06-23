part of 'confirm_cart_cubit.dart';

sealed class ConfirmCartState extends Equatable {
  const ConfirmCartState();

  @override
  List<Object> get props => [];
}

final class ConfirmCartInitial extends ConfirmCartState {}

final class ConfirmCartLoading extends ConfirmCartState {}

final class ConfirmCartSuccess extends ConfirmCartState {
  final String success;
  const ConfirmCartSuccess(this.success);
}

final class ConfirmCartFailure extends ConfirmCartState {
  final String errMessage;
  const ConfirmCartFailure(this.errMessage);
}
