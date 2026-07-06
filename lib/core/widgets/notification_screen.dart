import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/user/presentation/cubits/notification/notification_cubit.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/widgets/app_style.dart';
import 'package:ship_link/user/presentation/screens/order_detail/order_detail.dart';
import 'package:ship_link/user/presentation/screens/chat/order_chat_screen.dart';
import 'package:ship_link/user/presentation/screens/chat/chat_screen.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});
  static String routName = '/notifications';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NotificationCubit(),
      child: _NotificationBody(),
    );
  }
}

class _NotificationBody extends StatefulWidget {
  const _NotificationBody();

  @override
  State<_NotificationBody> createState() => _NotificationBodyState();
}

class _NotificationBodyState extends State<_NotificationBody> {
  late final NotificationCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<NotificationCubit>();
    _cubit.listen();
  }

  void _navigateToNotification(Map<String, dynamic> notif) {
    final typeRaw = notif['type'] as String? ?? 'general';
    String type;
    int? orderId;
    String? driverId;

    try {
      final decoded = jsonDecode(typeRaw) as Map<String, dynamic>;
      type = decoded['type'] as String? ?? 'general';
      if (decoded['orderId'] != null) {
        orderId = decoded['orderId'] is int
            ? decoded['orderId'] as int
            : int.tryParse(decoded['orderId'].toString());
      }
      driverId = decoded['driverId'] as String?;
    } catch (_) {
      type = typeRaw;
    }

    orderId ??= _parseOrderIdFromBody(notif['body'] as String?);

    switch (type) {
      case 'order_chat':
        final oId = orderId;
        final dId = driverId;
        if (oId != null && dId != null) {
          Navigator.push(context, MaterialPageRoute(
            builder: (_) => OrderChatScreen(orderId: oId, driverId: dId),
          ));
        }
        break;
      case 'chat':
        Navigator.pushNamed(context, Chat.routName);
        break;
      case 'order_accepted':
      case 'order_picked_up':
      case 'order_shipped':
      case 'order_delivered':
      case 'order_cancelled':
        final oId = orderId;
        if (oId != null) {
          Navigator.pushNamed(context, OrderDetail.routName, arguments: oId);
        }
        break;
    }
  }

  int? _parseOrderIdFromBody(String? body) {
    if (body == null) return null;
    final match = RegExp(r'#(\d+)').firstMatch(body);
    if (match == null) return null;
    return int.tryParse(match.group(1)!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.tr('notifications')),
        backgroundColor: const Color(0xFF1a1a2e),
      ),
      body: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading || state is NotificationInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is NotificationError) {
            return Center(child: Text(state.message));
          }
          if (state is NotificationLoaded) {
            final notifications = state.notifications;
            if (notifications.isEmpty) {
              return Center(child: Text(context.t.tr('no_notifications_yet')));
            }
            return ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (_, i) {
                final n = notifications[i];
                return ListTile(
                  onTap: () => _navigateToNotification(n),
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
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (n['read'] != true)
                        TextButton(
                          onPressed: () => _cubit.markRead(n['id']),
                          child: Text(context.t.tr('mark_read')),
                        ),
                      IconButton(
                        icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
                        onPressed: () => _cubit.deleteNotification(n['id']),
                      ),
                    ],
                  ),
                );
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
