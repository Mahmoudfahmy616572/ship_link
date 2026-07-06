import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/driver/data/models/update_user_data/up_user_data.dart';
import 'package:ship_link/driver/domain/repositories/driver_home_repository.dart';

part 'up_date_user_data_state.dart';

class UpDateUserDataCubit extends Cubit<UpDateUserDataState> {
  UpDateUserDataCubit(this.driverHomeServeices)
      : super(UpDateUserDataInitial());
  final DriverHomeRepository driverHomeServeices;
  Future<void> updateUserData(
      {String? name, String? phoneNumber}) async {
    emit(UpDateUserDataILoading());
    var result = await driverHomeServeices.updateUserData(
      phoneNumber: phoneNumber!,
      name: name!,
    );
    result.fold(
      (failure) {
        print(failure.errMessage);
        if (failure.errMessage ==
            "type 'Null' is not a subtype of type 'UpDateUserData'") {
          emit(const UpDateUserDataFailure('Succes Update'));
        } else {
          emit(UpDateUserDataFailure(failure.errMessage));
        }
      },
      (success) {
        print(success);

        emit(UpDateUserDataSuccess(success));
      },
    );
  }
}
