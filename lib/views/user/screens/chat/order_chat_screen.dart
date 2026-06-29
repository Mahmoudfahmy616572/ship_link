import 'package:flutter/material.dart';
import 'package:ship_link/utils/sizer.dart';
import 'package:ship_link/constant/colors.dart';
import 'package:ship_link/localization.dart';
import 'package:ship_link/services/notification_service.dart';
import 'package:ship_link/views/shared/app_style.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrderChatScreen extends StatefulWidget {
  final int orderId;
  final String driverId;

  const OrderChatScreen({
    super.key,
    required this.orderId,
    required this.driverId,
  });

  @override
  State<OrderChatScreen> createState() => _OrderChatScreenState();
}

class _OrderChatScreenState extends State<OrderChatScreen> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  List<Map<String, dynamic>> _messages = [];
  bool _loading = true;
  bool _sending = false;
  RealtimeChannel? _channel;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _subscribe();
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    _channel?.unsubscribe();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    final data = await Supabase.instance.client
        .from('order_chat_messages')
        .select()
        .eq('order_id', widget.orderId)
        .order('created_at', ascending: true);
    if (mounted) {
      setState(() {
        _messages = List<Map<String, dynamic>>.from(data);
        _loading = false;
      });
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _subscribe() {
    _channel = Supabase.instance.client.channel('order_chat_${widget.orderId}');
    _channel!.onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'order_chat_messages',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'order_id',
        value: widget.orderId.toString(),
      ),
      callback: (payload) {
        if (mounted) { setState(() => _messages.add(payload.newRecord)); }
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      },
    );
    _channel!.subscribe();
  }

  void _scrollToBottom() {
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  Future<void> _sendMessage() async {
    if (_sending) return;
    final text = _msgCtrl.text.trim();
    if (text.isEmpty || text.length > 2000) return;
    _sending = true;
    _msgCtrl.clear();
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    final role = userId == widget.driverId ? 'driver' : 'user';
    try {
      await Supabase.instance.client.from('order_chat_messages').insert({
        'order_id': widget.orderId,
        'sender_id': userId,
        'sender_role': role,
        'message': text,
      });
    } catch (_) {
      await Supabase.instance.client.from('profiles').upsert({
        'id': userId,
        'role': role,
      });
      await Supabase.instance.client.from('order_chat_messages').insert({
        'order_id': widget.orderId,
        'sender_id': userId,
        'sender_role': role,
        'message': text,
      });
    }
    _notifyOther(role, text);
    _sending = false;
  }

  Future<void> _notifyOther(String role, String text) async {
    final otherId = role == 'user' ? widget.driverId : null;
    final otherUserId = otherId ?? await _getOrderUserId();
    if (otherUserId == null) return;
    await NotificationService().sendNotification(
      userId: otherUserId,
      title: role == 'user' ? 'Driver Message' : 'New Message',
      body: text,
      type: 'order_chat',
      data: {'orderId': widget.orderId, 'driverId': widget.driverId},
    );
  }

  Future<String?> _getOrderUserId() async {
    final data = await Supabase.instance.client
        .from('orders')
        .select('user_id')
        .eq('id', widget.orderId)
        .maybeSingle();
    return data?['user_id'] as String?;
  }

  @override
  Widget build(BuildContext context) {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16213e),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order #${widget.orderId}',
                style: appStyle(17, FontWeight.w600, Colors.white)),
            Text(context.t.tr('online'),
                style: appStyle(13, FontWeight.normal, Colors.grey)),
          ],
        ),
        leading: Padding(
          padding: EdgeInsets.all(7.w),
          child: CircleAvatar(
            backgroundColor: Colors.white24,
            child: Icon(Icons.chat, color: Colors.white, size: 22.sp),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Column(
              children: [
                Expanded(
                  child: _messages.isEmpty
                      ? Center(
                          child: Text('Send a message to start chatting',
                              style: appStyle(15, FontWeight.w400, Colors.grey)),
                        )
                      : ListView.builder(
                          controller: _scrollCtrl,
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                          itemCount: _messages.length,
                          itemBuilder: (_, i) {
                            final msg = _messages[i];
                            final isMine = msg['sender_id'] == userId;
                            return _MessageBubble(
                              message: msg['message'] ?? '',
                              isMine: isMine,
                            );
                          },
                        ),
                ),
                Container(
                  padding: EdgeInsets.all(10.w),
                  color: const Color(0xFF16213e),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _msgCtrl,
                          style: const TextStyle(color: Colors.white),
                          maxLength: 2000,
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            hintStyle: TextStyle(color: Colors.grey[500]),
                            filled: true,
                            fillColor: const Color(0xFF0f3460),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                            counterStyle: TextStyle(color: Colors.grey[600], fontSize: 11.sp),
                          ),
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      CircleAvatar(
                        backgroundColor: AppColors.cta,
                        child: IconButton(
                          icon: Icon(Icons.send, color: Colors.white, size: 20.sp),
                          onPressed: _sendMessage,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final String message;
  final bool isMine;
  const _MessageBubble({required this.message, required this.isMine});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: isMine ? AppColors.cta : const Color(0xFF0f3460),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.r),
                  topRight: Radius.circular(20.r),
                  bottomLeft: isMine ? Radius.circular(20.r) : Radius.zero,
                  bottomRight: isMine ? Radius.zero : Radius.circular(20.r),
                ),
              ),
              child: Text(message, style: TextStyle(color: Colors.white, fontSize: 15.sp)),
            ),
          ),
        ],
      ),
    );
  }
}
