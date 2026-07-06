import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationPreferences {
  final bool orderUpdates;
  final bool chatMessages;
  final bool promotions;

  const NotificationPreferences({
    this.orderUpdates = true,
    this.chatMessages = true,
    this.promotions = false,
  });

  Map<String, dynamic> toMap() => {
    'order_updates': orderUpdates,
    'chat_messages': chatMessages,
    'promotions': promotions,
  };

  static NotificationPreferences fromMap(Map<String, dynamic>? map) {
    if (map == null) return const NotificationPreferences();
    return NotificationPreferences(
      orderUpdates: map['order_updates'] as bool? ?? true,
      chatMessages: map['chat_messages'] as bool? ?? true,
      promotions: map['promotions'] as bool? ?? false,
    );
  }
}

class NotificationPreferencesService {
  static final NotificationPreferencesService _instance = NotificationPreferencesService._();
  factory NotificationPreferencesService() => _instance;
  NotificationPreferencesService._();

  final _supabase = Supabase.instance.client;
  NotificationPreferences _cached = const NotificationPreferences();

  NotificationPreferences get cached => _cached;

  Future<NotificationPreferences> load() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return _cached;
    final data = await _supabase
        .from('notification_preferences')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
    _cached = NotificationPreferences.fromMap(data);
    return _cached;
  }

  Future<void> save(NotificationPreferences prefs) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;
    await _supabase.from('notification_preferences').upsert({
      'user_id': userId,
      ...prefs.toMap(),
      'updated_at': DateTime.now().toIso8601String(),
    });
    _cached = prefs;
  }
}
