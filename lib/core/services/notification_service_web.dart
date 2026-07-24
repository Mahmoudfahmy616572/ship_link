import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ship_link/core/config.dart';
import 'package:ship_link/core/widgets/snackBar/snack_bar.dart';
import 'package:ship_link/core/services/notification_preferences_service.dart';
import 'package:ship_link/core/services/order_mute_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  final SupabaseClient _supabase = Supabase.instance.client;
  RealtimeChannel? _notifChannel;
  Timer? _pollTimer;
  int _lastNotifId = 0;
  final Set<String> _recentNotifs = {};

  Future<void> initialize() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      _startPolling(user.id);
      _subscribeNotifChannel(user.id);
      NotificationPreferencesService().load();
    }
    _supabase.auth.onAuthStateChange.listen((event) async {
      _pollTimer?.cancel();
      _notifChannel?.unsubscribe();
      if (event.session?.user != null) {
        final uid = event.session!.user.id;
        _startPolling(uid);
        _subscribeNotifChannel(uid);
        NotificationPreferencesService().load();
      }
    });
  }

  void _subscribeNotifChannel(String userId) {
    try {
      _notifChannel?.unsubscribe();
      _notifChannel = _supabase
          .channel('notifications_realtime')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'notifications',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'user_id',
              value: userId,
            ),
            callback: (payload) {
              final row = payload.newRecord;
              if (row['user_id'] != userId) return;
              final title = row['title'] as String? ?? 'ShipLink';
              final body = row['body'] as String? ?? '';
              final type = row['type'] as String? ?? 'general';
              _showIfNew(title, body, type);
            },
          )
          .subscribe();
    } catch (_) {}
  }

  Future<void> _startPolling(String userId) async {
    _pollTimer?.cancel();
    try {
      final latest = await _supabase
          .from('notifications')
          .select('id')
          .eq('user_id', userId)
          .order('id', ascending: false)
          .limit(1)
          .maybeSingle();
      _lastNotifId = (latest?['id'] as int?) ?? 0;
    } catch (_) {}
    _pollTimer = Timer.periodic(const Duration(seconds: 10), (_) => _pollNotifications(userId));
  }

  Future<void> _pollNotifications(String userId) async {
    try {
      final rows = await _supabase
          .from('notifications')
          .select('id, title, body, type')
          .eq('user_id', userId)
          .gt('id', _lastNotifId)
          .order('id', ascending: true);
      for (final row in rows) {
        final id = row['id'] as int;
        if (id <= _lastNotifId) continue;
        _lastNotifId = id;
        final title = row['title'] as String? ?? 'ShipLink';
        final body = row['body'] as String? ?? '';
        final type = row['type'] as String? ?? 'general';
        _showIfNew(title, body, type);
      }
    } catch (_) {}
  }

  void _showIfNew(String title, String body, String type, {Map<String, dynamic>? data}) {
    final key = '$title|$body|$type';
    if (_recentNotifs.contains(key)) return;
    _recentNotifs.add(key);
    Future.delayed(const Duration(seconds: 3), () => _recentNotifs.remove(key));
    _showSnackBar(title, body);
  }

  void _showSnackBar(String title, String body) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = navigatorKey.currentContext;
      if (context == null) return;
      CustomSnackBar.info('$title${body.isNotEmpty ? '\n$body' : ''}', context);
    });
  }

  Future<void> sendNotification({
    required String userId,
    required String title,
    required String body,
    String? type,
    Map<String, dynamic>? data,
  }) async {
    final rawType = type ?? 'general';
    try {
      final receiverPrefs = await _supabase
          .from('notification_preferences')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      final prefs = NotificationPreferences.fromMap(receiverPrefs);
      if (rawType == 'order_chat' && !prefs.chatMessages) return;
      if (rawType == 'promotion' && !prefs.promotions) return;
      if (rawType != 'order_chat' && rawType != 'promotion' && !prefs.orderUpdates) return;
    } catch (_) {}
    final orderId = data?['orderId']?.toString();
    if (orderId != null) {
      try {
        if (await OrderMuteService().isMuted(orderId)) return;
      } catch (_) {}
    }
    final typeValue = data != null ? jsonEncode({'type': rawType, ...data}) : rawType;
    await _supabase.from('notifications').insert({
      'user_id': userId,
      'title': title,
      'body': body,
      'type': typeValue,
      'read': false,
      'created_at': DateTime.now().toIso8601String(),
    });
    try {
      await _supabase.functions.invoke('send_push', body: {
        'userId': userId,
        'title': title,
        'body': body,
        'type': rawType,
        'orderId': data?['orderId'],
        'driverId': data?['driverId'],
      });
    } catch (_) {}
  }
}
