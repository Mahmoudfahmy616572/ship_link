import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ship_link/data/models/getStates/get_states.dart';

import '../../data/services/DriverHomeServeices/driver_home_serveices.dart';

part 'get_states_state.dart';

class GetStatesCubit extends Cubit<GetStatesState> {
  GetStatesCubit(this.driverHomeServeices) : super(GetStatesInitial());
  final DriverHomeServeices driverHomeServeices;
  Future<void> getStates({String? selectedState}) async {
    emit(GetStatesLoading());

    var result =
        await driverHomeServeices.getStates(selectedState: selectedState!);
    result.fold(
      (failure) {
        emit(GetStatesFailure(failure.errMessage));
      },
      (states) {
        emit(GetStatesSuccess(states));
      },
    );
  }
}
