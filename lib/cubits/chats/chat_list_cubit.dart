import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

sealed class ChatListState extends Equatable {
  const ChatListState();
  @override List<Object?> get props => [];
}

final class ChatListIdle extends ChatListState {
  const ChatListIdle();
}

final class ChatListSelectionActive extends ChatListState {
  final Set<int> selectedIds;
  const ChatListSelectionActive(this.selectedIds);
  @override List<Object?> get props => [selectedIds];
}

class ChatListCubit extends Cubit<ChatListState> {
  ChatListCubit() : super(const ChatListIdle());

  void toggleSelection(int orderId) {
    final current = state;
    if (current is ChatListSelectionActive) {
      final updated = Set<int>.from(current.selectedIds);
      if (updated.contains(orderId)) {
        updated.remove(orderId);
      } else {
        updated.add(orderId);
      }
      emit(updated.isEmpty ? const ChatListIdle() : ChatListSelectionActive(updated));
    } else {
      emit(ChatListSelectionActive({orderId}));
    }
  }

  void clearSelection() {
    emit(const ChatListIdle());
  }

  Set<int> get selectedIds {
    final s = state;
    return s is ChatListSelectionActive ? s.selectedIds : const {};
  }
}
