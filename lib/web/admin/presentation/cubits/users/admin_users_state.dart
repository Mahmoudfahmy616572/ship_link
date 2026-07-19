abstract class AdminUsersState {}

class AdminUsersInitial extends AdminUsersState {}

class AdminUsersLoading extends AdminUsersState {}

class AdminUsersLoaded extends AdminUsersState {
  final List<Map<String, dynamic>> users;
  final bool hasMore;

  AdminUsersLoaded(this.users, {this.hasMore = false});
}

class AdminUserDeleteSuccess extends AdminUsersState {
  final String id;

  AdminUserDeleteSuccess(this.id);
}

class AdminUsersError extends AdminUsersState {
  final String message;
  AdminUsersError(this.message);
}
