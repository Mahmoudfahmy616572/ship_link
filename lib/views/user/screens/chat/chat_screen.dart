import 'package:flutter/material.dart';
import 'package:ship_link/utils/sizer.dart';
import 'package:ship_link/constant/colors.dart';
import 'package:ship_link/localization.dart';
import 'package:ship_link/views/shared/app_style.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Chat extends StatefulWidget {
  const Chat({super.key});
  static String routName = '/ChatScreen';

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  List<Map<String, dynamic>> _messages = [];
  bool _loading = true;
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
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    final data = await Supabase.instance.client
        .from('support_messages')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: true);
    if (mounted) setState(() {
      _messages = List<Map<String, dynamic>>.from(data);
      _loading = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _subscribe() {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    _channel = Supabase.instance.client.channel('support_messages');
    _channel!.onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'support_messages',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'user_id',
        value: userId,
      ),
      callback: (payload) {
        if (mounted) setState(() => _messages.add(payload.newRecord));
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      },
    );
    _channel!.subscribe();
  }

  void _scrollToBottom() {
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  Future<void> _sendMessage() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    _msgCtrl.clear();
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    await Supabase.instance.client.from('support_messages').insert({
      'user_id': userId,
      'message': text,
      'sender_role': 'user',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16213e),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Support', style: appStyle(17, FontWeight.w600, Colors.white)),
            Text(context.t.tr('online'), style: appStyle(13, FontWeight.normal, Colors.grey)),
          ],
        ),
        leading: Padding(
          padding: EdgeInsets.all(7.w),
          child: CircleAvatar(
            backgroundImage: AssetImage('assets/images/robot.png'),
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
                            final isMine = msg['sender_role'] == 'user';
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
          if (!isMine) Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: CircleAvatar(
              radius: 14.r,
              backgroundImage: AssetImage('assets/images/robot.png'),
            ),
          ),
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
