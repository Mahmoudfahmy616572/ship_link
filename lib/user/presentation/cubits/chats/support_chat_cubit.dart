import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'support_chat_state.dart';

class SupportChatCubit extends Cubit<SupportChatState> {
  final _supabase = Supabase.instance.client;
  RealtimeChannel? _channel;

  SupportChatCubit() : super(const SupportChatInitial());

  void loadMessages() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;
    emit(const SupportChatLoading());
    _load(userId);
    _subscribe(userId);
  }

  Future<void> _load(String userId) async {
    final data = await _supabase
        .from('support_messages')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: true);
    if (!isClosed) emit(SupportChatLoaded(
      List<Map<String, dynamic>>.from(data),
      const {},
    ));
  }

  void _subscribe(String userId) {
    _channel = _supabase.channel('support_messages');
    _channel!.onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'support_messages',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'user_id',
        value: userId,
      ),
      callback: (payload) {
        final current = state;
        if (current is SupportChatLoaded) {
          final updated = [...current.messages, payload.newRecord];
          if (!isClosed) emit(SupportChatLoaded(updated, current.selectedIds));
        }
      },
    );
    _channel!.subscribe();
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;
    await _supabase.from('support_messages').insert({
      'user_id': userId,
      'message': text,
      'sender_role': 'user',
    });
  }

  void toggleSelection(int id) {
    final current = state;
    if (current is! SupportChatLoaded) return;
    final selected = Set<int>.from(current.selectedIds);
    if (selected.contains(id)) {
      selected.remove(id);
    } else {
      selected.add(id);
    }
    if (!isClosed) emit(SupportChatLoaded(current.messages, selected));
  }

  void clearSelection() {
    final current = state;
    if (current is! SupportChatLoaded) return;
    if (!isClosed) emit(SupportChatLoaded(current.messages, const {}));
  }

  Future<void> deleteSelected() async {
    final current = state;
    if (current is! SupportChatLoaded || current.selectedIds.isEmpty) return;
    final ids = current.selectedIds.toList();
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;
    for (final id in ids) {
      await _supabase
          .from('support_messages')
          .delete()
          .eq('id', id)
          .eq('user_id', userId);
    }
    final updated = current.messages.where((m) => !ids.contains(m['id'])).toList();
    if (!isClosed) emit(SupportChatLoaded(updated, const {}));
  }

  void shareSelected() {
    final current = state;
    if (current is! SupportChatLoaded || current.selectedIds.isEmpty) return;
    final texts = current.messages
        .where((m) => current.selectedIds.contains(m['id']))
        .map((m) => '${m['message']}')
        .join('\n\n');
    if (texts.isNotEmpty) SharePlus.instance.share(ShareParams(text: texts));
    if (!isClosed) emit(SupportChatLoaded(current.messages, const {}));
  }

  @override
  Future<void> close() {
    _channel?.unsubscribe();
    return super.close();
  }
}
