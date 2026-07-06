part of 'order_chat_cubit.dart';

sealed class OrderChatState extends Equatable {
  const OrderChatState();
  @override
  List<Object?> get props => [];
}

final class OrderChatInitial extends OrderChatState {
  const OrderChatInitial();
}

final class OrderChatLoading extends OrderChatState {
  const OrderChatLoading();
}

final class OrderChatLoaded extends OrderChatState {
  final List<Map<String, dynamic>> messages;
  final Set<int> selectedIds;
  const OrderChatLoaded(this.messages, this.selectedIds);
  @override
  List<Object?> get props => [messages, selectedIds];
}

final class OrderChatError extends OrderChatState {
  final String message;
  const OrderChatError(this.message);
  @override
  List<Object?> get props => [message];
}
