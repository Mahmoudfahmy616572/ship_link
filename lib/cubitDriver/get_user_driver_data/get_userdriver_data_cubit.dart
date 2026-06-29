import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ship_link/data/models/getUserDriverData/get_user_driver_data.dart';
import 'package:ship_link/services/cache_service.dart';

import '../../data/services/DriverHomeServeices/driver_home_serveices.dart';

part 'get_userdriver_data_state.dart';

class GetUserdriverDataCubit extends Cubit<GetUserdriverDataState> {
  GetUserdriverDataCubit(this.driverHomeServeices)
      : super(GetUserdriverDataInitial());
  final DriverHomeServeices driverHomeServeices;
  final _cache = CacheService();
  static const _cacheKey = 'cached_driver_profile';

  Future<void> getuserDriverData() async {
    emit(GetUserdriverDataLoading());
    var result = await driverHomeServeices.getuserData();
    result.fold(
      (failure) async {
        final cached = await _cache.get(_cacheKey);
        if (cached != null) {
          final data = GetuserDriverData.fromJson(cached);
          emit(GetUserdriverDataSuccess(data, isOffline: true));
        } else {
          emit(GetUserdriverDataFailure(failure.errMessage));
        }
      },
      (data) async {
        await _cache.put(_cacheKey, data.toJson(), ttl: const Duration(hours: 1));
        emit(GetUserdriverDataSuccess(data));
      },
    );
  }
}
