import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/web/admin/domain/repositories/admin_repository.dart';
import 'package:ship_link/web/admin/presentation/cubits/users/admin_users_state.dart';

export 'package:ship_link/web/admin/presentation/cubits/users/admin_users_state.dart';

class AdminUsersCubit extends Cubit<AdminUsersState> {
  AdminUsersCubit(this._repository) : super(AdminUsersInitial());

  final AdminRepository _repository;

  static AdminUsersCubit get(context) => BlocProvider.of<AdminUsersCubit>(context);

  Future<void> loadUsers({int limit = 20, int offset = 0, String? search, bool append = false}) async {
    if (!append) {
      if (!isClosed) emit(AdminUsersLoading());
    }
    final result = await _repository.getUsers(limit: limit, offset: offset, search: search);
    result.fold(
      (failure) {
        if (!isClosed) emit(AdminUsersError(failure.errMessage));
      },
      (users) {
        if (!isClosed) {
          final current = append && state is AdminUsersLoaded ? (state as AdminUsersLoaded).users : <Map<String, dynamic>>[];
          final merged = [...current, ...users];
          emit(AdminUsersLoaded(merged, hasMore: users.length >= limit));
        }
      },
    );
  }

  Future<void> deleteUser(String id) async {
    if (!isClosed) emit(AdminUsersLoading());
    final result = await _repository.deleteUser(id);
    result.fold(
      (failure) {
        if (!isClosed) emit(AdminUsersError(failure.errMessage));
      },
      (_) {
        if (!isClosed) emit(AdminUserDeleteSuccess(id));
      },
    );
  }

  Future<void> loadMoreUsers({String? search}) async {
    if (state is! AdminUsersLoaded) return;
    final loaded = state as AdminUsersLoaded;
    if (!loaded.hasMore) return;
    await loadUsers(offset: loaded.users.length, search: search, append: true);
  }
}
