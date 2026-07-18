abstract class AdminUsersState {}

class AdminUsersInitial extends AdminUsersState {}

class AdminUsersLoading extends AdminUsersState {}

class AdminUsersLoaded extends AdminUsersState {
  final List<Map<String, dynamic>> users;
  AdminUsersLoaded(this.users);
}

class AdminUsersError extends AdminUsersState {
  final String message;
  AdminUsersError(this.message);
}
