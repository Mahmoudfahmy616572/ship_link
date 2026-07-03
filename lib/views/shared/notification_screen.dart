import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/cubits/notification/notification_cubit.dart';
import 'package:ship_link/localization.dart';
import 'app_style.dart';

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
