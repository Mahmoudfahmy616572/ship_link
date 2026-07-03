import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ship_link/services/notification_service.dart';

part 'order_chat_state.dart';

class OrderChatCubit extends Cubit<OrderChatState> {
  final _supabase = Supabase.instance.client;
  RealtimeChannel? _channel;
  final int orderId;
  final String driverId;

  OrderChatCubit({required this.orderId, required this.driverId})
      : super(const OrderChatInitial());

  void loadMessages() {
    emit(const OrderChatLoading());
    _load();
    _subscribe();
  }

  Future<void> _load() async {
    final data = await _supabase
        .from('order_chat_messages')
        .select()
        .eq('order_id', orderId)
        .order('created_at', ascending: true);
    if (!isClosed) emit(OrderChatLoaded(
      List<Map<String, dynamic>>.from(data),
      const {},
    ));
  }

  void _subscribe() {
    _channel = _supabase.channel('order_chat_$orderId');
    _channel!.onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'order_chat_messages',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'order_id',
        value: orderId.toString(),
      ),
      callback: (payload) {
        final current = state;
        if (current is OrderChatLoaded) {
          final updated = [...current.messages, payload.newRecord];
          if (!isClosed) emit(OrderChatLoaded(updated, current.selectedIds));
        }
      },
    );
    _channel!.subscribe();
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || text.length > 2000) return;
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;
    final role = userId == driverId ? 'driver' : 'user';
    try {
      await _supabase.from('order_chat_messages').insert({
        'order_id': orderId,
        'sender_id': userId,
        'sender_role': role,
        'message': text,
      });
    } catch (_) {
      await _supabase.from('profiles').upsert({
        'id': userId,
        'role': role,
      });
      await _supabase.from('order_chat_messages').insert({
        'order_id': orderId,
        'sender_id': userId,
        'sender_role': role,
        'message': text,
      });
    }
    _notifyOther(role, text);
  }

  Future<void> _notifyOther(String role, String text) async {
    final otherId = role == 'user' ? driverId : await _getOrderUserId();
    if (otherId == null) return;
    await NotificationService().sendNotification(
      userId: otherId,
      title: role == 'user' ? 'Driver Message' : 'New Message',
      body: text,
      type: 'order_chat',
      data: {'orderId': orderId, 'driverId': driverId},
    );
  }

  Future<String?> _getOrderUserId() async {
    final data = await _supabase
        .from('orders')
        .select('user_id')
        .eq('id', orderId)
        .maybeSingle();
    return data?['user_id'] as String?;
  }

  void toggleSelection(int id) {
    final current = state;
    if (current is! OrderChatLoaded) return;
    final selected = Set<int>.from(current.selectedIds);
    if (selected.contains(id)) {
      selected.remove(id);
    } else {
      selected.add(id);
    }
    if (!isClosed) emit(OrderChatLoaded(current.messages, selected));
  }

  void clearSelection() {
    final current = state;
    if (current is! OrderChatLoaded) return;
    if (!isClosed) emit(OrderChatLoaded(current.messages, const {}));
  }

  Future<void> deleteSelected() async {
    final current = state;
    if (current is! OrderChatLoaded || current.selectedIds.isEmpty) return;
    final ids = current.selectedIds.toList();
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;
    for (final id in ids) {
      await _supabase
          .from('order_chat_messages')
          .delete()
          .eq('id', id)
          .eq('sender_id', userId);
    }
    final updated = current.messages.where((m) => !ids.contains(m['id'])).toList();
    if (!isClosed) emit(OrderChatLoaded(updated, const {}));
  }

  void shareSelected() {
    final current = state;
    if (current is! OrderChatLoaded || current.selectedIds.isEmpty) return;
    final texts = current.messages
        .where((m) => current.selectedIds.contains(m['id']))
        .map((m) => '${m['message']}')
        .join('\n\n');
    if (texts.isNotEmpty) SharePlus.instance.share(ShareParams(text: texts));
    if (!isClosed) emit(OrderChatLoaded(current.messages, const {}));
  }

  @override
  Future<void> close() {
    _channel?.unsubscribe();
    return super.close();
  }
}
