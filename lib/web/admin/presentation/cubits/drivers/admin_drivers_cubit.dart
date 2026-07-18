import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/web/admin/domain/repositories/admin_repository.dart';
import 'package:ship_link/web/admin/presentation/cubits/drivers/admin_drivers_state.dart';

export 'package:ship_link/web/admin/presentation/cubits/drivers/admin_drivers_state.dart';

class AdminDriversCubit extends Cubit<AdminDriversState> {
  AdminDriversCubit(this._repository) : super(AdminDriversInitial());

  final AdminRepository _repository;

  static AdminDriversCubit get(context) => BlocProvider.of<AdminDriversCubit>(context);

  Future<void> loadDrivers({int limit = 50, int offset = 0, String? search}) async {
    if (!isClosed) emit(AdminDriversLoading());
    final result = await _repository.getDrivers(limit: limit, offset: offset, search: search);
    result.fold(
      (failure) {
        if (!isClosed) emit(AdminDriversError(failure.errMessage));
      },
      (drivers) {
        if (!isClosed) emit(AdminDriversLoaded(drivers));
      },
    );
  }

  Future<void> updateDriver({required String id, required Map<String, dynamic> fields}) async {
    final result = await _repository.updateDriver(id: id, fields: fields);
    result.fold(
      (failure) {
        if (!isClosed) emit(AdminDriversError(failure.errMessage));
      },
      (_) {
        if (!isClosed) emit(AdminDriverUpdateSuccess(id));
      },
    );
  }
}
