import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app_style.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});
  static String routName = '/notifications';

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final _supabase = Supabase.instance.client;
  StreamSubscription? _sub;
  List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _listen();
  }

  void _listen() {
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    _sub = _supabase
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', user.id)
        .order('created_at', ascending: false)
        .listen((data) {
      if (mounted) setState(() => _notifications = data);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _markRead(int id) async {
    await _supabase.from('notifications').update({'read': true}).eq('id', id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: const Color(0xFF1a1a2e),
      ),
      body: _notifications.isEmpty
          ? const Center(child: Text('No notifications yet'))
          : ListView.builder(
              itemCount: _notifications.length,
              itemBuilder: (_, i) {
                final n = _notifications[i];
                return ListTile(
                  leading: Icon(
                    n['read'] == true
                        ? Icons.notifications_none
                        : Icons.notifications_active,
                    color: n['read'] == true ? Colors.grey : Colors.blue,
                  ),
                  title: Text('${n['title']}',
                      style: appStyle(
                          16,
                          FontWeight.w500,
                          n['read'] == true ? Colors.grey : Colors.black)),
                  subtitle: Text('${n['body']}',
                      style: appStyle(13, FontWeight.normal, Colors.grey)),
                  trailing: n['read'] == true
                      ? null
                      : TextButton(
                          onPressed: () => _markRead(n['id']),
                          child: const Text('Mark read'),
                        ),
                );
              },
            ),
    );
  }
}
