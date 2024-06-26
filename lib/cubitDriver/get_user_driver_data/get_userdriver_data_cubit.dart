import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ship_link/data/models/getUserDriverData/get_user_driver_data.dart';

import '../../data/services/DriverHomeServeices/driver_home_serveices.dart';

part 'get_userdriver_data_state.dart';

class GetUserdriverDataCubit extends Cubit<GetUserdriverDataState> {
  GetUserdriverDataCubit(this.driverHomeServeices)
      : super(GetUserdriverDataInitial());
  final DriverHomeServeices driverHomeServeices;
  Future<void> getuserDriverData() async {
    emit(GetUserdriverDataLoading());
    var result = await driverHomeServeices.getuserData();
    result.fold(
      (failure) {
        emit(GetUserdriverDataFailure(failure.errMessage));
      },
      (order) {
        emit(GetUserdriverDataSuccess(order));
      },
    );
  }
}
