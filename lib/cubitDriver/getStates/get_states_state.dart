part of 'get_states_cubit.dart';

sealed class GetStatesState extends Equatable {
  const GetStatesState();

  @override
  List<Object> get props => [];
}

final class GetStatesInitial extends GetStatesState {}

final class GetStatesLoading extends GetStatesState {}

final class GetStatesSuccess extends GetStatesState {
  final GetStates getStates;
  const GetStatesSuccess(this.getStates);
}

final class GetStatesFailure extends GetStatesState {
  final String errMessage;
  const GetStatesFailure(this.errMessage);
}
