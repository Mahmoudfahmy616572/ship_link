part of 'support_chat_cubit.dart';

sealed class SupportChatState extends Equatable {
  const SupportChatState();
  @override
  List<Object?> get props => [];
}

final class SupportChatInitial extends SupportChatState {
  const SupportChatInitial();
}

final class SupportChatLoading extends SupportChatState {
  const SupportChatLoading();
}

final class SupportChatLoaded extends SupportChatState {
  final List<Map<String, dynamic>> messages;
  final Set<int> selectedIds;
  const SupportChatLoaded(this.messages, this.selectedIds);
  @override
  List<Object?> get props => [messages, selectedIds];
}

final class SupportChatError extends SupportChatState {
  final String message;
  const SupportChatError(this.message);
  @override
  List<Object?> get props => [message];
}
