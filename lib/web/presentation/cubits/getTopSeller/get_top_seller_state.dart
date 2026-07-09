part of 'get_top_seller_cubit.dart';

sealed class GetTopSellerState extends Equatable {
  const GetTopSellerState();

  @override
  List<Object> get props => [];
}

final class GetTopSellerInitial extends GetTopSellerState {}

final class GetTopSellerLoading extends GetTopSellerState {}

final class GetTopSellerFailure extends GetTopSellerState {
  final String errMessage;
  const GetTopSellerFailure(this.errMessage);
}

final class GetTopSellerSuccess extends GetTopSellerState {
  final GetTopSeller getTopSeller;
  const GetTopSellerSuccess(this.getTopSeller);
}
