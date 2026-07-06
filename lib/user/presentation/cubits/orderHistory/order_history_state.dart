abstract class OrderHistoryState {}

class OrderHistoryInitial extends OrderHistoryState {}

class OrderHistoryLoading extends OrderHistoryState {}

class OrderHistoryLoaded extends OrderHistoryState {
  final List<Map<String, dynamic>> orders;
  OrderHistoryLoaded(this.orders);
}

class OrderHistoryError extends OrderHistoryState {
  final String message;
  OrderHistoryError(this.message);
}
