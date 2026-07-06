import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ship_link/core/utils/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ship_link/core/widgets/notification_screen.dart';

class NotificationBell extends StatefulWidget {
  final Color? iconColor;
  const NotificationBell({super.key, this.iconColor});

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  final _supabase = Supabase.instance.client;
  final ValueNotifier<int> _unread = ValueNotifier(0);
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
      _unread.value = data.where((n) => n['read'] == false).length;
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
          ValueListenableBuilder<int>(
            valueListenable: _unread,
            builder: (context, unread, _) {
              if (unread <= 0) return const SizedBox.shrink();
              return Positioned(
                right: -4,
                top: -4,
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    unread > 99 ? '99+' : '$unread',
                    style: TextStyle(color: Colors.white, fontSize: 9.sp, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      onPressed: () => Navigator.pushNamed(context, NotificationScreen.routName),
    );
  }
}
