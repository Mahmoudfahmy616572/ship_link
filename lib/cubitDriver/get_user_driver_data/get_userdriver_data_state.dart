part of 'get_userdriver_data_cubit.dart';

sealed class GetUserdriverDataState extends Equatable {
  const GetUserdriverDataState();

  @override
  List<Object> get props => [];
}

final class GetUserdriverDataInitial extends GetUserdriverDataState {}

final class GetUserdriverDataLoading extends GetUserdriverDataState {}

final class GetUserdriverDataSuccess extends GetUserdriverDataState {
  final GetuserDriverData getuserDriverData;
  final bool isOffline;
  const GetUserdriverDataSuccess(this.getuserDriverData, {this.isOffline = false});
}

final class GetUserdriverDataFailure extends GetUserdriverDataState {
  final String errMessage;
  const GetUserdriverDataFailure(this.errMessage);
}
