abstract class AdminDriversState {}

class AdminDriversInitial extends AdminDriversState {}

class AdminDriversLoading extends AdminDriversState {}

class AdminDriversLoaded extends AdminDriversState {
  final List<Map<String, dynamic>> drivers;
  AdminDriversLoaded(this.drivers);
}

class AdminDriversError extends AdminDriversState {
  final String message;
  AdminDriversError(this.message);
}

class AdminDriverUpdateSuccess extends AdminDriversState {
  final String id;
  AdminDriverUpdateSuccess(this.id);
}
