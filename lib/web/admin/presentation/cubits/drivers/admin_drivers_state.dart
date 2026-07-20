abstract class AdminDriversState {}

class AdminDriversInitial extends AdminDriversState {}

class AdminDriversLoading extends AdminDriversState {}

class AdminDriversLoaded extends AdminDriversState {
  final List<Map<String, dynamic>> drivers;
  final bool hasMore;
  AdminDriversLoaded(this.drivers, {this.hasMore = false});
}

class AdminDriversError extends AdminDriversState {
  final String message;
  AdminDriversError(this.message);
}

class AdminDriverUpdateSuccess extends AdminDriversState {
  final String id;
  AdminDriverUpdateSuccess(this.id);
}

class AdminDriversBulkDeleteSuccess extends AdminDriversState {
  final int count;
  AdminDriversBulkDeleteSuccess(this.count);
}
