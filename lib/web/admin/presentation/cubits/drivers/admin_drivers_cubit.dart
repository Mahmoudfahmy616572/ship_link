import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/web/admin/domain/repositories/admin_repository.dart';
import 'package:ship_link/web/admin/presentation/cubits/drivers/admin_drivers_state.dart';

export 'package:ship_link/web/admin/presentation/cubits/drivers/admin_drivers_state.dart';

class AdminDriversCubit extends Cubit<AdminDriversState> {
  AdminDriversCubit(this._repository) : super(AdminDriversInitial());

  final AdminRepository _repository;

  static AdminDriversCubit get(context) => BlocProvider.of<AdminDriversCubit>(context);

  Future<void> loadDrivers({int limit = 20, int offset = 0, String? search, bool append = false}) async {
    if (!append) {
      if (!isClosed) emit(AdminDriversLoading());
    }
    final result = await _repository.getDrivers(limit: limit, offset: offset, search: search);
    result.fold(
      (failure) {
        if (!isClosed) emit(AdminDriversError(failure.errMessage));
      },
      (drivers) {
        if (!isClosed) {
          final current = append && state is AdminDriversLoaded ? (state as AdminDriversLoaded).drivers : <Map<String, dynamic>>[];
          final merged = [...current, ...drivers];
          emit(AdminDriversLoaded(merged, hasMore: drivers.length >= limit));
        }
      },
    );
  }

  Future<void> loadMoreDrivers({String? search}) async {
    if (state is! AdminDriversLoaded) return;
    final loaded = state as AdminDriversLoaded;
    if (!loaded.hasMore) return;
    await loadDrivers(offset: loaded.drivers.length, search: search, append: true);
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
