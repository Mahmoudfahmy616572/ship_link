import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ship_link/driver/presentation/screens/DriverHome/components/body.dart';

class DriverHome extends StatefulWidget {
  const DriverHome({super.key});
  static String routName = '/ProfileDriver';

  @override
  State<DriverHome> createState() => _DriverHomeState();
}

class _DriverHomeState extends State<DriverHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: const Body(),
      floatingActionButton: FloatingActionButton(
        mini: true,
        onPressed: _showDebug,
        child: const Icon(Icons.bug_report, size: 18),
      ),
    );
  }

  Future<void> _showDebug() async {
    String msg = '';
    try {
      final token = await FirebaseMessaging.instance.getToken();
      msg += 'FCM token: ${token ?? 'NULL'}\n\n';
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        msg += 'User: ${user.id}\n';
        final r = await Supabase.instance.client
            .from('profiles')
            .select('fcm_token')
            .eq('id', user.id)
            .maybeSingle();
        msg += 'DB fcm_token: ${r?['fcm_token'] ?? 'NULL'}';
      } else {
        msg += 'No user logged in';
      }
    } catch (e) {
      msg = 'Error: $e';
    }
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('FCM Debug'),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
