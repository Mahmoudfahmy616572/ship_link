import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotifiedBell extends StatefulWidget {
  const NotifiedBell({super.key});

  @override
  State<NotifiedBell> createState() => _NotifiedBellState();
}

class _NotifiedBellState extends State<NotifiedBell> {
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
    return Stack(
      children: [
        const Icon(
          color: Color(0xFF303030),
          Icons.notifications_outlined,
          size: 30,
        ),
        if (_unread > 0)
          Positioned(
              right: 2,
              top: 2,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: Colors.red),
              )),
      ],
    );
  }
}