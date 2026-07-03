import 'package:flutter/material.dart';
import 'package:ship_link/localization.dart';
import 'package:ship_link/constant/colors.dart';
import 'package:ship_link/views/shared/app_style.dart';
import 'package:ship_link/views/web/shared/hover_widget.dart';
import 'package:ship_link/utils/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationsWeb extends StatefulWidget {
  const NotificationsWeb({super.key});
  static String routName = '/notifications';

  @override
  State<NotificationsWeb> createState() => _NotificationsWebState();
}

class _NotificationsWebState extends State<NotificationsWeb> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _notifications = [];
  bool _loading = true;
  late AnimationController _animCtrl;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _load();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    try {
      final data = await Supabase.instance.client
          .from('notifications')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);
      if (mounted) setState(() => _notifications = List<Map<String, dynamic>>.from(data));
    } catch (_) {}
    if (mounted) { setState(() => _loading = false); _animCtrl.forward(); }
  }

  Future<void> _markRead(String id) async {
    await Supabase.instance.client.from('notifications').update({'is_read': true}).eq('id', id);
    _load();
  }

  Future<void> _delete(String id) async {
    await Supabase.instance.client.from('notifications').delete().eq('id', id);
    _load();
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'order_update': return Icons.inventory_2;
      case 'chat': return Icons.chat;
      case 'promotion': return Icons.discount;
      default: return Icons.notifications;
    }
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'order_update': return AppColors.primary;
      case 'chat': return const Color(0xFF3B82F6);
      case 'promotion': return const Color(0xFFF59E0B);
      default: return const Color(0xFF6B7280);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.tr('notifications')),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0.5,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.notifications_none, size: 64, color: const Color(0xFFD1D5DB)),
                      SizedBox(height: 16),
                      Text(context.t.tr('no_notifications_yet'),
                          style: appStyle(16, FontWeight.w500, const Color(0xFF9CA3AF))),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: _notifications.length,
                  itemBuilder: (_, i) {
                    final n = _notifications[i];
                    final type = n['type'] as String? ?? '';
                    final title = n['title'] as String? ?? '';
                    final body = n['body'] as String? ?? '';
                    final isRead = n['is_read'] as bool? ?? false;
                    final createdAt = n['created_at'] as String? ?? '';
                    final date = createdAt.length >= 10 ? createdAt.substring(0, 10) : '';

                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: Duration(milliseconds: 200 + (i * 50)),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) => Opacity(opacity: value, child: Transform.translate(
                        offset: Offset(0, 15 * (1 - value)), child: child,
                      )),
                      child: HoverScale(
                        scale: 1.01,
                        onTap: isRead ? null : () => _markRead(n['id']),
                        child: Container(
                          margin: EdgeInsets.only(bottom: 8),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isRead ? Colors.white : const Color(0xFFF0F9FF),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isRead ? const Color(0xFFE5E7EB) : AppColors.primary.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _typeColor(type).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(_typeIcon(type), color: _typeColor(type), size: 20),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(title,
                                              style: appStyle(14, FontWeight.w600, const Color(0xFF111827))),
                                        ),
                                        if (!isRead)
                                          Container(
                                            width: 8, height: 8,
                                            decoration: BoxDecoration(
                                              color: AppColors.primary,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                      ],
                                    ),
                                    if (body.isNotEmpty) ...[
                                      SizedBox(height: 4),
                                      Text(body, style: appStyle(13, FontWeight.w400, const Color(0xFF6B7280))),
                                    ],
                                    if (date.isNotEmpty) ...[
                                      SizedBox(height: 4),
                                      Text(date, style: appStyle(11, FontWeight.w400, const Color(0xFF9CA3AF))),
                                    ],
                                  ],
                                ),
                              ),
                              PopupMenuButton<String>(
                                icon: Icon(Icons.more_vert, size: 18, color: const Color(0xFF9CA3AF)),
                                onSelected: (v) {
                                  if (v == 'read' && !isRead) _markRead(n['id']);
                                  if (v == 'delete') _delete(n['id']);
                                },
                                itemBuilder: (_) => [
                                  if (!isRead)
                                    PopupMenuItem(value: 'read', child: Text(context.t.tr('mark_as_read'))),
                                  PopupMenuItem(value: 'delete', child: Text(context.t.tr('delete'), style: TextStyle(color: AppColors.error))),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
