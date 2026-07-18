import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/web/admin/domain/repositories/admin_repository.dart';
import 'package:ship_link/web/admin/presentation/cubits/dashboard/admin_dashboard_state.dart';

export 'package:ship_link/web/admin/presentation/cubits/dashboard/admin_dashboard_state.dart';

class AdminDashboardCubit extends Cubit<AdminDashboardState> {
  AdminDashboardCubit(this._repository) : super(AdminDashboardInitial());

  final AdminRepository _repository;

  static AdminDashboardCubit get(context) => BlocProvider.of<AdminDashboardCubit>(context);

  Future<void> loadStats() async {
    if (!isClosed) emit(AdminDashboardLoading());
    final result = await _repository.getDashboardStats();
    result.fold(
      (failure) {
        if (!isClosed) emit(AdminDashboardError(failure.errMessage));
      },
      (stats) {
        if (!isClosed) emit(AdminDashboardLoaded(stats));
      },
    );
  }
}
