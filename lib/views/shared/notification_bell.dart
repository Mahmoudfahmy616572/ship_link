import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ship_link/utils/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'notification_screen.dart';

class NotificationBell extends StatefulWidget {
  final Color? iconColor;
  const NotificationBell({super.key, this.iconColor});

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  final _supabase = Supabase.instance.client;
  int _unread = 0;
  StreamSubscription? _sub;

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
        .listen((data) {
      if (mounted) {
        setState(() => _unread = data.where((n) => n['read'] == false).length);
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(Icons.notifications_outlined, color: widget.iconColor ?? Colors.white, size: 28.sp),
          if (_unread > 0)
            Positioned(
              right: -4,
              top: -4,
              child: Container(
                padding: EdgeInsets.all(4.w),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  _unread > 99 ? '99+' : '$_unread',
                  style: TextStyle(color: Colors.white, fontSize: 9.sp, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
      onPressed: () => Navigator.pushNamed(context, NotificationScreen.routName),
    );
  }
}
