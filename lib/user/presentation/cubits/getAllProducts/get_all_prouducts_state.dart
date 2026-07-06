part of 'get_all_prouducts_cubit.dart';

sealed class GetAllProuductsState extends Equatable {
  const GetAllProuductsState();

  @override
  List<Object> get props => [];
}

class GetAllProuductsInitial extends GetAllProuductsState {}

class GetAllProuductsLoading extends GetAllProuductsState {}

class GetAllProuductsSuccess extends GetAllProuductsState {
  final AllProducts products;

  const GetAllProuductsSuccess(this.products);
}

class GetAllProuductsFailure extends GetAllProuductsState {
  final String errMessage;

  const GetAllProuductsFailure(this.errMessage);
}
