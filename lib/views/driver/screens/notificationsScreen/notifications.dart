import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:ship_link/views/shared/app_style.dart';

import 'components/body.dart';
import 'components/notified_bell.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});
  static String routName = '/NotificationScreen';

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool isNotified = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCDCDCD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFCDCDCD),
        centerTitle: true,
        title: Text(
          "Notifications",
          style: appStyle(18, FontWeight.bold, const Color(0xFF303030)),
        ),
        actions: [
          isNotified
              ? const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: NotifiedBell(),
                )
              : const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Ionicons.notifications_outline,
                    size: 30,
                    color: Color(0xFF303030),
                  ),
                ),
        ],
      ),
      body: const Body(),
    );
  }
}
