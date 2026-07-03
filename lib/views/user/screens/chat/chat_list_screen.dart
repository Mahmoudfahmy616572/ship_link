import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:ship_link/constant/colors.dart';
import 'package:ship_link/localization.dart';
import 'package:ship_link/utils/sizer.dart';
import 'package:ship_link/views/shared/app_style.dart';
import 'package:ship_link/views/user/screens/chat/order_chat_screen.dart';
import 'package:ship_link/cubits/chats/chat_list_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final _supabase = Supabase.instance.client;
  List<_ChatItem> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    final orders = await _supabase
        .from('orders')
        .select('*, drivers(name)')
        .eq('user_id', userId)
        .not('driver_id', 'is', null)
        .order('created_at', ascending: false);

    final List<_ChatItem> items = [];
    for (final order in orders) {
      final latest = await _supabase
          .from('order_chat_messages')
          .select('message, created_at, sender_role')
          .eq('order_id', order['id'])
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      final unreadMsgs = await _supabase
          .from('order_chat_messages')
          .select('id')
          .eq('order_id', order['id'])
          .eq('sender_role', 'driver')
          .eq('read', false);

      if (latest != null || order['driver_id'] != null) {
        items.add(_ChatItem(
          orderId: order['id'] as int,
          driverId: order['driver_id'] as String,
          driverName: order['drivers']?['name'] ?? 'Driver',
          lastMessage: latest?['message'] as String?,
          lastTime: latest?['created_at'] != null
              ? DateTime.tryParse(latest!['created_at'] as String)
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

  Future<void> _deleteSelected(Set<int> ids) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;
      for (final orderId in ids) {
        await _supabase
            .from('order_chat_messages')
            .delete()
            .eq('order_id', orderId)
            .eq('sender_id', userId);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Messages deleted')),
        );
        _load();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: $e')),
        );
      }
    }
  }

  Future<void> _shareSelected(Set<int> ids) async {
    try {
      final data = await _supabase
          .from('order_chat_messages')
          .select('message, sender_role, created_at')
          .inFilter('order_id', ids.toList())
          .order('created_at', ascending: true);
      final text = data.map((m) {
        final role = m['sender_role'] == 'user' ? '👤' : '🚚';
        return '$role ${m['message']}';
      }).join('\n');
      if (text.isNotEmpty) {
        await SharePlus.instance.share(ShareParams(text: text));
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChatListCubit(),
      child: BlocBuilder<ChatListCubit, ChatListState>(
        builder: (context, state) {
          final inSelection = state is ChatListSelectionActive;
          final selectedIds = state is ChatListSelectionActive ? state.selectedIds : const <int>{};
          final cubit = context.read<ChatListCubit>();
          return Scaffold(
            appBar: AppBar(
              title: inSelection
                  ? Text('${selectedIds.length} selected',
                      style: appStyle(17, FontWeight.w600, Colors.white))
                  : Text(context.t.tr('my_chats')),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              leading: inSelection
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: cubit.clearSelection,
                    )
                  : null,
              actions: inSelection
                  ? [
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () {
                          _deleteSelected(selectedIds);
                          cubit.clearSelection();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.share, color: Colors.white),
                        onPressed: () {
                          _shareSelected(selectedIds);
                          cubit.clearSelection();
                        },
                      ),
                    ]
                  : null,
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
                              Text('Chat with drivers after placing an order',
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
                          itemBuilder: (_, i) => _ChatTile(
                            item: _items[i],
                            inSelection: inSelection,
                            selected: selectedIds.contains(_items[i].orderId),
                            onLongPress: () => cubit.toggleSelection(_items[i].orderId),
                            onTap: inSelection
                                ? () => cubit.toggleSelection(_items[i].orderId)
                                : () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => OrderChatScreen(
                                        orderId: _items[i].orderId,
                                        driverId: _items[i].driverId,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ),
          );
        },
      ),
    );
  }
}

class _ChatItem {
  final int orderId;
  final String driverId;
  final String driverName;
  final String? lastMessage;
  final DateTime? lastTime;
  final int unread;

  const _ChatItem({
    required this.orderId,
    required this.driverId,
    required this.driverName,
    this.lastMessage,
    this.lastTime,
    this.unread = 0,
  });
}

class _ChatTile extends StatelessWidget {
  final _ChatItem item;
  final bool inSelection;
  final bool selected;
  final VoidCallback onLongPress;
  final VoidCallback onTap;

  const _ChatTile({
    required this.item,
    required this.inSelection,
    required this.selected,
    required this.onLongPress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      onTap: onTap,
      child: ListTile(
        selected: selected,
        selectedTileColor: AppColors.primary.withValues(alpha: 0.15),
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          child: inSelection
              ? Icon(
                  selected ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: selected ? AppColors.cta : Colors.grey,
                  size: 24.sp,
                )
              : Icon(Icons.person, color: AppColors.primary, size: 24.sp),
        ),
        title: Text(item.driverName,
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
