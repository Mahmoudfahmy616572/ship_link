part of 'get_from_cart_cubit.dart';

sealed class GetFromCartState extends Equatable {
  const GetFromCartState();

  @override
  List<Object> get props => [];
}

final class GetFromCartInitial extends GetFromCartState {}

final class GetFromCartLoading extends GetFromCartState {}

final class GetFromCartFailure extends GetFromCartState {
  final String errMessage;
  const GetFromCartFailure(this.errMessage);
}

final class GetFromCartSuccess extends GetFromCartState {
  final GetFromCart getProductFromCart;
  const GetFromCartSuccess(this.getProductFromCart);
}
final class DeleteFromCartLoading extends GetFromCartState {}

final class DeleteFromCartSuccess extends GetFromCartState {
  final String success;
  const DeleteFromCartSuccess(this.success);
}

final class DeleteFromCartFailure extends GetFromCartState {
  final String errMassege;
  const DeleteFromCartFailure(this.errMassege);
}

