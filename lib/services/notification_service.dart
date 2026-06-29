import 'dart:async';
import 'dart:convert';
import 'package:ship_link/utils/sizer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../firebase_options.dart';
import '../views/user/screens/chat/order_chat_screen.dart';
import 'notification_preferences_service.dart';
import 'order_mute_service.dart';

const String _channelId = 'ship_link_channel';
const String _channelName = 'ShipLink Notifications';
const String _channelDesc = 'Order updates and promotions';

@pragma('vm:entry-point')
Future<void> _backgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final notif = message.notification;
  final title = notif?.title ?? message.data['title'] as String? ?? 'ShipLink';
  final body = notif?.body ?? message.data['body'] as String? ?? '';
  final type = message.data['type'] as String? ?? 'general';
  final payloadData = jsonEncode({
    'type': type,
    'orderId': message.data['orderId'],
    'driverId': message.data['driverId'],
  });
  final flp = FlutterLocalNotificationsPlugin();
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  await flp.initialize(const InitializationSettings(android: androidSettings));
  await flp.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(
    const AndroidNotificationChannel(_channelId, _channelName,
        description: _channelDesc, importance: Importance.high, playSound: true, enableVibration: true),
  );
  await flp.show(
    DateTime.now().millisecondsSinceEpoch % 100000,
    title, body,
    const NotificationDetails(
      android: AndroidNotificationDetails(_channelId, _channelName,
          channelDescription: _channelDesc, importance: Importance.high, priority: Priority.high,
          playSound: true, enableVibration: true),
    ),
    payload: payloadData,
  );
}

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  FirebaseMessaging? _fcm;
  final SupabaseClient _supabase = Supabase.instance.client;
  late final FlutterLocalNotificationsPlugin _localNotifs;

  bool _localNotifsInitialized = false;
  RealtimeChannel? _notifChannel;
  Timer? _pollTimer;
  int _lastNotifId = 0;
  final Set<String> _recentNotifs = {};

  Future<void> initialize() async {
    if (Firebase.apps.isNotEmpty) {
      _fcm = FirebaseMessaging.instance;
    }
    await _initLocalNotifications();
    if (_fcm != null) {
      await _requestPermission();
    }
    try {
      if (_fcm == null) throw 'FCM unavailable';
      final token = await _fcm!.getToken();
      if (token != null) await _saveToken(token);
      _fcm!.onTokenRefresh.listen(_saveToken);
      FirebaseMessaging.onBackgroundMessage(_backgroundHandler);
      FirebaseMessaging.onMessage.listen(_onForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_onNotificationTap);
      final initialMsg = await _fcm!.getInitialMessage();
      if (initialMsg != null) _handleTap(initialMsg.data);
    } catch (e) {
      debugPrint('FCM setup skipped: $e');
    }
    final user = _supabase.auth.currentUser;
    if (user != null) {
      _startPolling(user.id);
      _subscribeNotifChannel(user.id);
      NotificationPreferencesService().load();
    }
    _supabase.auth.onAuthStateChange.listen((event) {
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
      if (!_localNotifsInitialized) return;
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
    _showLocalNotif(title, body, type, data: data);
    _showSnackBar(title, body, type: type, data: data);
  }

  Future<void> _initLocalNotifications() async {
    _localNotifs = FlutterLocalNotificationsPlugin();
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false, requestBadgePermission: false, requestSoundPermission: false,
    );
    await _localNotifs.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null) {
          try {
            _handleTap(jsonDecode(payload) as Map<String, dynamic>);
          } catch (_) {
            _handleTap({'type': payload});
          }
        }
      },
    );
    await _localNotifs.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
      const AndroidNotificationChannel(_channelId, _channelName,
          description: _channelDesc, importance: Importance.high, playSound: true, enableVibration: true),
    );
    if (await _localNotifs.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
            ?.areNotificationsEnabled() == false) {
      await _localNotifs.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
    _localNotifsInitialized = true;
  }

  Future<void> _showLocalNotif(String title, String body, String type, {Map<String, dynamic>? data}) async {
    if (!_localNotifsInitialized) return;
    final payloadStr = data != null ? jsonEncode({'type': type, ...data}) : type;
    await _localNotifs.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      title, body,
      const NotificationDetails(
        android: AndroidNotificationDetails(_channelId, _channelName,
            channelDescription: _channelDesc, importance: Importance.high, priority: Priority.high,
            showWhen: true, enableVibration: true, playSound: true),
        iOS: DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true),
      ),
      payload: payloadStr,
    );
  }

  Future<void> _requestPermission() async {
    await _fcm!.requestPermission(alert: true, badge: true, sound: true, provisional: true);
  }

  Future<void> _saveToken(String token) async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      await _supabase.from('profiles').upsert({'id': user.id, 'fcm_token': token});
    }
  }

  void _onForegroundMessage(RemoteMessage message) {
    final title = message.notification?.title ?? message.data['title'] as String? ?? 'ShipLink';
    final body = message.notification?.body ?? message.data['body'] as String? ?? '';
    final type = message.data['type'] as String? ?? 'general';
    Map<String, dynamic>? data;
    if (message.data['orderId'] != null || message.data['driverId'] != null) {
      data = {
        if (message.data['orderId'] != null) 'orderId': message.data['orderId'],
        if (message.data['driverId'] != null) 'driverId': message.data['driverId'],
      };
    }
    _showIfNew(title, body, type, data: data);
  }

  void _onNotificationTap(RemoteMessage message) {
    _handleTap(message.data);
  }

  void _handleTap(Map<String, dynamic> data) {
    final context = navigatorKey.currentContext;
    if (context == null) return;
    var type = data['type'] as String?;
    Map<String, dynamic> resolved = data;
    if (type != null) {
      try {
        final decoded = jsonDecode(type) as Map<String, dynamic>;
        resolved = decoded;
        type = decoded['type'] as String?;
      } catch (_) {}
    }
    if (type == 'order_chat') {
      final orderId = resolved['orderId'] is int
          ? resolved['orderId'] as int
          : int.parse(resolved['orderId'] as String);
      final driverId = resolved['driverId'] as String;
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => OrderChatScreen(orderId: orderId, driverId: driverId),
      ));
    } else if (type == 'chat') {
      Navigator.pushNamed(context, '/ChatScreen');
    } else {
      Navigator.pushNamed(context, '/notifications');
    }
  }

  void _showSnackBar(String title, String body, {String? type, Map<String, dynamic>? data}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = navigatorKey.currentContext;
      if (context == null) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
            if (body.isNotEmpty) Text(body, style: TextStyle(fontSize: 13.sp)),
          ],
        ),
        backgroundColor: const Color(0xFF1a1a2e),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.fromLTRB(12.w, 0.h, 12.w, 80.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'View',
          textColor: Colors.orange,
          onPressed: () => _handleTap(data != null ? {...data, 'type': type} : {'type': type}),
        ),
      ));
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
    final prefs = NotificationPreferencesService().cached;
    if (rawType == 'order_chat' && !prefs.chatMessages) return;
    if (rawType == 'promotion' && !prefs.promotions) return;
    if (rawType != 'order_chat' && rawType != 'promotion' && !prefs.orderUpdates) return;
    final orderId = data?['orderId']?.toString();
    if (orderId != null && await OrderMuteService().isMuted(orderId)) return;
    final typeValue = data != null
        ? jsonEncode({'type': rawType, ...data})
        : rawType;
    await _supabase.from('notifications').insert({
      'user_id': userId,
      'title': title,
      'body': body,
      'type': typeValue,
      'read': false,
      'created_at': DateTime.now().toIso8601String(),
    });
  }
}
