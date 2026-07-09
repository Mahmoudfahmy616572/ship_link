import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/widgets/app_style.dart';
import 'package:ship_link/core/utils/sizer.dart';
import 'package:ship_link/web/presentation/cubits/chats/support_chat_cubit.dart';

class SupportChatWeb extends StatelessWidget {
  const SupportChatWeb({super.key});
  static String routName = '/support-chat';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SupportChatCubit(),
      child: const _SupportChatBody(),
    );
  }
}

class _SupportChatBody extends StatefulWidget {
  const _SupportChatBody();

  @override
  State<_SupportChatBody> createState() => _SupportChatBodyState();
}

class _SupportChatBodyState extends State<_SupportChatBody> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  late final SupportChatCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<SupportChatCubit>();
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
    final cubit = _cubit;
    return BlocBuilder<SupportChatCubit, SupportChatState>(
      builder: (context, state) {
        final selectedIds = state is SupportChatLoaded ? state.selectedIds : const <int>{};
        final inSelection = selectedIds.isNotEmpty;
        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          appBar: AppBar(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF111827),
            elevation: 0.5,
            leading: inSelection
                ? IconButton(icon: const Icon(Icons.close), onPressed: cubit.clearSelection)
                : null,
            title: inSelection
                ? Text('${selectedIds.length} selected',
                    style: appStyle(17, FontWeight.w600, const Color(0xFF111827)))
                : Text(context.t.tr('support'),
                    style: appStyle(18, FontWeight.w600, const Color(0xFF111827))),
            actions: inSelection
                ? [
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: cubit.deleteSelected,
                    ),
                  ]
                : null,
          ),
          body: state is SupportChatLoading
              ? const Center(child: CircularProgressIndicator())
              : state is SupportChatLoaded
                  ? Column(
                      children: [
                        Expanded(
                          child: state.messages.isEmpty
                              ? Center(
                                  child: Text(context.t.tr('send_message_to_start'),
                                      style: appStyle(15, FontWeight.w400, const Color(0xFFD1D5DB))),
                                )
                              : ListView.builder(
                                  controller: _scrollCtrl,
                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  itemCount: state.messages.length,
                                  itemBuilder: (_, i) {
                                    final msg = state.messages[i];
                                    final msgId = msg['id'] as int;
                                    final isMine = msg['sender_role'] == 'user';
                                    final selected = selectedIds.contains(msgId);
                                    return GestureDetector(
                                      onLongPress: () => cubit.toggleSelection(msgId),
                                      onTap: inSelection ? () => cubit.toggleSelection(msgId) : null,
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
      padding: EdgeInsets.all(10),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _msgCtrl,
              decoration: InputDecoration(
                hintText: context.t.tr('type_message'),
                hintStyle: TextStyle(color: const Color(0xFF9CA3AF)),
                filled: true,
                fillColor: const Color(0xFFF3F4F6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _send(),
            ),
          ),
          SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: AppColors.cta,
            child: IconButton(
              icon: Icon(Icons.send, color: Colors.white, size: 20),
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
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (showCheck && isMine)
            Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(
                selected ? Icons.check_circle : Icons.radio_button_unchecked,
                color: selected ? AppColors.cta : const Color(0xFFD1D5DB),
                size: 22,
              ),
            ),
          Flexible(
            child: Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.cta.withValues(alpha: 0.7)
                    : isMine
                        ? AppColors.cta
                        : const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: isMine ? Radius.circular(20) : Radius.zero,
                  bottomRight: isMine ? Radius.zero : Radius.circular(20),
                ),
              ),
              child: Text(message,
                  style: TextStyle(
                    color: isMine ? Colors.white : const Color(0xFF111827),
                    fontSize: 15,
                  )),
            ),
          ),
          if (showCheck && !isMine)
            Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(
                selected ? Icons.check_circle : Icons.radio_button_unchecked,
                color: selected ? AppColors.cta : const Color(0xFFD1D5DB),
                size: 22,
              ),
            ),
        ],
      ),
    );
  }
}
