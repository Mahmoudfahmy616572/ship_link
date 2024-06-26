part of 'up_date_user_data_cubit.dart';

sealed class UpDateUserDataState extends Equatable {
  const UpDateUserDataState();

  @override
  List<Object> get props => [];
}

final class UpDateUserDataInitial extends UpDateUserDataState {}

final class UpDateUserDataILoading extends UpDateUserDataState {}

final class UpDateUserDataSuccess extends UpDateUserDataState {
  final UpDateUserData upDateUserData;
  const UpDateUserDataSuccess(this.upDateUserData);
}

final class UpDateUserDataFailure extends UpDateUserDataState {
  final String errMessage;
  const UpDateUserDataFailure(this.errMessage);
}
