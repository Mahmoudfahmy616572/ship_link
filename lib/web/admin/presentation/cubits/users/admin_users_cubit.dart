import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/web/admin/domain/repositories/admin_repository.dart';
import 'package:ship_link/web/admin/presentation/cubits/users/admin_users_state.dart';

export 'package:ship_link/web/admin/presentation/cubits/users/admin_users_state.dart';

class AdminUsersCubit extends Cubit<AdminUsersState> {
  AdminUsersCubit(this._repository) : super(AdminUsersInitial());

  final AdminRepository _repository;

  static AdminUsersCubit get(context) => BlocProvider.of<AdminUsersCubit>(context);

  Future<void> loadUsers({int limit = 50, int offset = 0, String? search}) async {
    if (!isClosed) emit(AdminUsersLoading());
    final result = await _repository.getUsers(limit: limit, offset: offset, search: search);
    result.fold(
      (failure) {
        if (!isClosed) emit(AdminUsersError(failure.errMessage));
      },
      (users) {
        if (!isClosed) emit(AdminUsersLoaded(users));
      },
    );
  }
}
