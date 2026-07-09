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

  @override
  List<Object> get props => [errMessage];
}

final class GetFromCartSuccess extends GetFromCartState {
  final GetFromCart getProductFromCart;
  const GetFromCartSuccess(this.getProductFromCart);

  @override
  List<Object> get props => [getProductFromCart];
}
final class DeleteFromCartLoading extends GetFromCartState {}

final class DeleteFromCartSuccess extends GetFromCartState {
  final String success;
  const DeleteFromCartSuccess(this.success);

  @override
  List<Object> get props => [success];
}

final class DeleteFromCartFailure extends GetFromCartState {
  final String errMassege;
  const DeleteFromCartFailure(this.errMassege);

  @override
  List<Object> get props => [errMassege];
}
