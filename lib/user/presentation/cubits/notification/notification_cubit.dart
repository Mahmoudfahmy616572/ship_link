import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final _supabase = Supabase.instance.client;
  StreamSubscription? _sub;

  NotificationCubit() : super(const NotificationInitial());

  void listen() {
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    emit(const NotificationLoading());
    _sub = _supabase
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', user.id)
        .order('created_at', ascending: false)
        .listen((data) {
      if (!isClosed) emit(NotificationLoaded(List<Map<String, dynamic>>.from(data)));
    });
  }

  Future<void> markRead(int id) async {
    await _supabase.from('notifications').update({'read': true}).eq('id', id);
  }

  Future<void> deleteNotification(int id) async {
    await _supabase.from('notifications').delete().eq('id', id);
    final current = state;
    if (current is NotificationLoaded) {
      final updated = current.notifications.where((n) => n['id'] != id).toList();
      if (!isClosed) emit(NotificationLoaded(updated));
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
