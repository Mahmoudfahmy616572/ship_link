part of 'add_to_cart_cubit.dart';

sealed class AddToCartState extends Equatable {
  const AddToCartState();

  @override
  List<Object> get props => [];
}

final class AddToCartInitial extends AddToCartState {}

final class AddToCartLoading extends AddToCartState {}

final class AddToCartFailure extends AddToCartState {
  final String errMessage;
  const AddToCartFailure(this.errMessage);
}

final class AddToCartSuccess extends AddToCartState {
  final String success;
  const AddToCartSuccess(this.success);
}
