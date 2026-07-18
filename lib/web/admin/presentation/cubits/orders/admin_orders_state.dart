abstract class AdminOrdersState {}

class AdminOrdersInitial extends AdminOrdersState {}

class AdminOrdersLoading extends AdminOrdersState {}

class AdminOrdersLoaded extends AdminOrdersState {
  final List<Map<String, dynamic>> orders;
  AdminOrdersLoaded(this.orders);
}

class AdminOrdersError extends AdminOrdersState {
  final String message;
  AdminOrdersError(this.message);
}

class AdminOrderUpdateSuccess extends AdminOrdersState {
  final int id;
  AdminOrderUpdateSuccess(this.id);
}

class AdminOrderDetailLoaded extends AdminOrdersState {
  final int orderId;
  final List<Map<String, dynamic>> items;
  final Map<String, dynamic>? order;
  AdminOrderDetailLoaded(this.orderId, this.items, {this.order});
}
