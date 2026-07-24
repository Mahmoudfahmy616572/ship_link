import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/core/constants/Errors/failures.dart';
import 'package:ship_link/driver/data/models/getUserDriverData/get_user_driver_data.dart';
import 'package:ship_link/web/driver/data/driver_web_repository.dart';

part 'get_userdriver_data_web_state.dart';

class GetUserdriverDataWebCubit extends Cubit<GetUserdriverDataWebState> {
  final DriverWebRepositoryImpl _repository;
  GetUserdriverDataWebCubit(this._repository) : super(GetUserdriverDataInitial());

  Future<void> getuserData() async {
    emit(GetUserdriverDataLoading());
    Either<Failure, GetuserDriverData> result = await _repository.getuserData();
    result.fold(
      (failure) => emit(GetUserdriverDataError(failure.errMessage)),
      (data) => emit(GetUserdriverDataSuccess(data)),
    );
  }
}
