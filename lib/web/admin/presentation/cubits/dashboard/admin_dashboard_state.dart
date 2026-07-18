abstract class AdminDashboardState {}

class AdminDashboardInitial extends AdminDashboardState {}

class AdminDashboardLoading extends AdminDashboardState {}

class AdminDashboardLoaded extends AdminDashboardState {
  final Map<String, dynamic> stats;
  AdminDashboardLoaded(this.stats);
}

class AdminDashboardError extends AdminDashboardState {
  final String message;
  AdminDashboardError(this.message);
}
