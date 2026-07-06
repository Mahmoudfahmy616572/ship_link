import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/user/presentation/cubits/chats/order_chat_cubit.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/utils/sizer.dart';
import 'package:ship_link/core/widgets/app_style.dart';

class OrderChatScreen extends StatelessWidget {
  final int orderId;
  final String driverId;

  const OrderChatScreen({
    super.key,
    required this.orderId,
    required this.driverId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OrderChatCubit(orderId: orderId, driverId: driverId),
      child: const _OrderChatBody(),
    );
  }
}

class _OrderChatBody extends StatefulWidget {
  const _OrderChatBody();

  @override
  State<_OrderChatBody> createState() => _OrderChatBodyState();
}

class _OrderChatBodyState extends State<_OrderChatBody> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  late final OrderChatCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<OrderChatCubit>();
    _cubit.loadMessages();
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<OrderChatCubit>();
    return BlocBuilder<OrderChatCubit, OrderChatState>(
      builder: (context, state) {
        final selectedIds =
            state is OrderChatLoaded ? state.selectedIds : const <int>{};
        final inSelection = selectedIds.isNotEmpty;
        return Scaffold(
          backgroundColor: const Color(0xFF1a1a2e),
          appBar: AppBar(
            backgroundColor: const Color(0xFF16213e),
            leading: inSelection
                ? IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: cubit.clearSelection,
                  )
                : Padding(
                    padding: EdgeInsets.all(7.w),
                    child: CircleAvatar(
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.chat, color: Colors.white, size: 22.sp),
                    ),
                  ),
            title: inSelection
                ? Text('${selectedIds.length} selected',
                    style: appStyle(17, FontWeight.w600, Colors.white))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Order #${cubit.orderId}',
                          style: appStyle(17, FontWeight.w600, Colors.white)),
                      Text(context.t.tr('online'),
                          style: appStyle(13, FontWeight.normal, Colors.grey)),
                    ],
                  ),
            actions: inSelection
                ? [
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: cubit.deleteSelected,
                    ),
                    IconButton(
                      icon: const Icon(Icons.share, color: Colors.white),
                      onPressed: cubit.shareSelected,
                    ),
                  ]
                : null,
          ),
          body: state is OrderChatLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white))
              : state is OrderChatLoaded
                  ? Column(
                      children: [
                        Expanded(
                          child: state.messages.isEmpty
                              ? Center(
                                  child: Text(
                                      'Send a message to start chatting',
                                      style: appStyle(
                                          15, FontWeight.w400, Colors.grey)),
                                )
                              : ListView.builder(
                                  controller: _scrollCtrl,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12.w, vertical: 8.h),
                                  itemCount: state.messages.length,
                                  itemBuilder: (_, i) {
                                    final msg = state.messages[i];
                                    final msgId = msg['id'] as int;
                                    final isMine =
                                        msg['sender_id'] == cubit.driverId;
                                    final selected =
                                        selectedIds.contains(msgId);
                                    return GestureDetector(
                                      onLongPress: () =>
                                          cubit.toggleSelection(msgId),
                                      onTap: inSelection
                                          ? () => cubit.toggleSelection(msgId)
                                          : null,
                                      child: _MessageBubble(
                                        message: msg['message'] ?? '',
                                        isMine: isMine,
                                        selected: selected,
                                        showCheck: inSelection,
                                      ),
                                    );
                                  },
                                ),
                        ),
                        _buildInput(),
                      ],
                    )
                  : const SizedBox(),
        );
      },
    );
  }

  Widget _buildInput() {
    return Container(
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
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                counterStyle:
                    TextStyle(color: Colors.grey[600], fontSize: 11.sp),
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _send(),
            ),
          ),
          SizedBox(width: 8.w),
          CircleAvatar(
            backgroundColor: AppColors.cta,
            child: IconButton(
              icon: Icon(Icons.send, color: Colors.white, size: 20.sp),
              onPressed: _send,
            ),
          ),
        ],
      ),
    );
  }

  void _send() {
    final text = _msgCtrl.text;
    if (text.trim().isEmpty) return;
    _msgCtrl.clear();
    _cubit.sendMessage(text);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }
}

class _MessageBubble extends StatelessWidget {
  final String message;
  final bool isMine;
  final bool selected;
  final bool showCheck;
  const _MessageBubble({
    required this.message,
    required this.isMine,
    this.selected = false,
    this.showCheck = false,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment:
            isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (showCheck && isMine)
            Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: Icon(
                selected ? Icons.check_circle : Icons.radio_button_unchecked,
                color: selected ? AppColors.cta : Colors.grey,
                size: 22.sp,
              ),
            ),
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.cta.withValues(alpha: 0.7)
                    : isMine
                        ? AppColors.cta
                        : const Color(0xFF0f3460),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.r),
                  topRight: Radius.circular(20.r),
                  bottomLeft: isMine ? Radius.circular(20.r) : Radius.zero,
                  bottomRight: isMine ? Radius.zero : Radius.circular(20.r),
                ),
              ),
              child: Text(message,
                  style: TextStyle(color: Colors.white, fontSize: 15.sp)),
            ),
          ),
          if (showCheck && !isMine)
            Padding(
              padding: EdgeInsets.only(left: 8.w),
              child: Icon(
                selected ? Icons.check_circle : Icons.radio_button_unchecked,
                color: selected ? AppColors.cta : Colors.grey,
                size: 22.sp,
              ),
            ),
        ],
      ),
    );
  }
}
