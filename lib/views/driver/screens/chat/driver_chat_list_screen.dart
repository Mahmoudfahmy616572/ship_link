import 'package:flutter/material.dart';
import 'package:ship_link/constant/colors.dart';
import 'package:ship_link/localization.dart';
import 'package:ship_link/utils/sizer.dart';
import 'package:ship_link/views/shared/app_style.dart';
import 'package:ship_link/views/user/screens/chat/order_chat_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DriverChatListScreen extends StatefulWidget {
  const DriverChatListScreen({super.key});
  static String routName = '/DriverChatList';

  @override
  State<DriverChatListScreen> createState() => _DriverChatListScreenState();
}

class _DriverChatListScreenState extends State<DriverChatListScreen> {
  final _supabase = Supabase.instance.client;
  List<_ChatItem> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final driverId = _supabase.auth.currentUser?.id;
    if (driverId == null) return;

    final orders = await _supabase
        .from('orders')
        .select('*, profiles!inner(name)')
        .eq('driver_id', driverId)
        .order('created_at', ascending: false);

    final List<_ChatItem> items = [];
    for (final order in orders) {
      final latest = await _supabase
          .from('order_chat_messages')
          .select('message, created_at')
          .eq('order_id', order['id'])
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      final unreadMsgs = await _supabase
          .from('order_chat_messages')
          .select('id')
          .eq('order_id', order['id'])
          .eq('sender_role', 'user')
          .eq('read', false);

      if (latest != null) {
        items.add(_ChatItem(
          orderId: order['id'] as int,
          driverId: driverId,
          userName: order['profiles']?['name'] ?? 'User',
          lastMessage: latest['message'] as String?,
          lastTime: latest['created_at'] != null
              ? DateTime.tryParse(latest['created_at'] as String)
              : null,
          unread: unreadMsgs.length,
        ));
      }
    }

    items.sort((a, b) {
      final aTime = a.lastTime ?? DateTime(2000);
      final bTime = b.lastTime ?? DateTime(2000);
      return bTime.compareTo(aTime);
    });

    if (mounted) setState(() { _items = items; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.tr('my_chats')),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 64.sp, color: AppColors.textDisabled),
                        SizedBox(height: 16.h),
                        Text('No chats yet',
                            style: appStyle(18, FontWeight.w600, AppColors.textSecondary)),
                        SizedBox(height: 8.h),
                        Text('Chat with users after accepting orders',
                            style: appStyle(14, FontWeight.normal, AppColors.textDisabled),
                            textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    itemCount: _items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) => _ChatTile(item: _items[i]),
                  ),
                ),
    );
  }
}

class _ChatItem {
  final int orderId;
  final String driverId;
  final String userName;
  final String? lastMessage;
  final DateTime? lastTime;
  final int unread;

  const _ChatItem({
    required this.orderId,
    required this.driverId,
    required this.userName,
    this.lastMessage,
    this.lastTime,
    this.unread = 0,
  });
}

class _ChatTile extends StatelessWidget {
  final _ChatItem item;
  const _ChatTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OrderChatScreen(orderId: item.orderId, driverId: item.driverId),
        ),
      ),
      leading: CircleAvatar(
        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
        child: Icon(Icons.person, color: AppColors.primary, size: 24.sp),
      ),
      title: Text(item.userName,
          style: appStyle(15, FontWeight.w600, AppColors.textPrimary)),
      subtitle: Text(
        item.lastMessage ?? 'No messages yet',
        style: appStyle(13, FontWeight.normal, AppColors.textSecondary),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (item.lastTime != null)
            Text(_formatTime(item.lastTime!),
                style: appStyle(11, FontWeight.normal, AppColors.textDisabled)),
          if (item.unread > 0) ...[
            SizedBox(height: 4.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: const BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
              child: Text(
                item.unread > 99 ? '99+' : '${item.unread}',
                style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${dt.day}/${dt.month}';
  }
}
