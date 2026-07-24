import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
    final color = widget.iconColor ?? Colors.white;
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, NotificationScreen.routName),
      child: Padding(
        padding: EdgeInsets.only(right: 12.w),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            SvgPicture.asset(
              'assets/icons/NotificationBell.svg',
              height: 24,
              width: 24,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            ),
            ValueListenableBuilder<int>(
              valueListenable: _unread,
              builder: (context, unread, _) {
                if (unread <= 0) return const SizedBox.shrink();
                return Positioned(
                  right: -6,
                  top: -6,
                  child: Container(
                    width: 18,
                    height: 18,
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          unread > 99 ? '99+' : '$unread',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
