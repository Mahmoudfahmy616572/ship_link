part of 'get_userdriver_data_web_cubit.dart';

sealed class GetUserdriverDataWebState {}

final class GetUserdriverDataInitial extends GetUserdriverDataWebState {}
final class GetUserdriverDataLoading extends GetUserdriverDataWebState {}
final class GetUserdriverDataSuccess extends GetUserdriverDataWebState {
  final GetuserDriverData userData;
  GetUserdriverDataSuccess(this.userData);
}
final class GetUserdriverDataError extends GetUserdriverDataWebState {
  final String message;
  GetUserdriverDataError(this.message);
}
