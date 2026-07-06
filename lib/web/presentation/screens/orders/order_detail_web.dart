import 'package:flutter/material.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/widgets/app_style.dart';
import 'package:ship_link/web/presentation/shared/hover_widget.dart';
import 'package:ship_link/web/presentation/shared/web_invoice_download.dart';
import 'package:ship_link/core/utils/sizer.dart';
import 'dart:async';
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrderDetailWeb extends StatefulWidget {
  final int orderId;
  const OrderDetailWeb({super.key, required this.orderId});
  static String routName = '/order-detail';

  @override
  State<OrderDetailWeb> createState() => _OrderDetailWebState();
}

class _OrderDetailWebState extends State<OrderDetailWeb> with SingleTickerProviderStateMixin {
  Map<String, dynamic>? _order;
  List<Map<String, dynamic>> _items = [];
  bool _loadingOrder = true;
  bool _loadingItems = true;
  bool _cancelling = false;
  int _rating = 0;
  bool _submittingRating = false;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic);
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

    _order = await Supabase.instance.client
        .from('orders')
        .select()
        .eq('id', widget.orderId)
        .eq('user_id', user.id)
        .maybeSingle();

    if (_order != null) {
      final rawItems = await Supabase.instance.client
          .from('order_items')
          .select('product_id, quantity')
          .eq('order_id', widget.orderId);
      _items = [];
      for (final item in rawItems) {
        final pid = item['product_id'] as int?;
        if (pid == null) continue;
        final product = await Supabase.instance.client
            .from('products')
            .select()
            .eq('id', pid)
            .maybeSingle();
        _items.add({
          'quantity': item['quantity'],
          'product_id': pid,
          'products': product,
        });
      }
    }

    if (mounted) {
      setState(() { _loadingOrder = false; _loadingItems = false; });
      _animCtrl.forward();
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return const Color(0xFFF59E0B);
      case 'shipped':
      case 'confirmed': return AppColors.primary;
      case 'in_transit': return const Color(0xFF3B82F6);
      case 'delivered': return AppColors.success;
      case 'cancelled':
      case 'canceled': return AppColors.error;
      default: return const Color(0xFF9CA3AF);
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.length < 10) return '';
    return dateStr.substring(0, 10);
  }

  Future<void> _cancelOrder() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.t.tr('cancel_order')),
        content: Text(context.t.tr('are_you_sure_cancel_order')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(context.t.tr('no'))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(context.t.tr('yes'), style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _cancelling = true);
    try {
      await Supabase.instance.client.from('orders').update({'status': 'cancelled'}).eq('id', widget.orderId);
      if (mounted) {
        setState(() { _order!['status'] = 'cancelled'; _cancelling = false; });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.t.tr('order_cancelled'))));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _cancelling = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _submitRating() async {
    if (_rating == 0 || _order == null) return;
    setState(() => _submittingRating = true);
    try {
      await Supabase.instance.client.from('driver_ratings').insert({
        'user_id': Supabase.instance.client.auth.currentUser?.id,
        'driver_id': _order!['driver_id'],
        'order_id': widget.orderId,
        'rating': _rating,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.t.tr('rating_submitted'))));
        setState(() => _submittingRating = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
        setState(() => _submittingRating = false);
      }
    }
  }

  void _showChatDialog(BuildContext context) {
    final driverId = _order?['driver_id'] as String? ?? '';
    if (driverId.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _WebChatScreen(orderId: widget.orderId, driverId: driverId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.tr('order_details')),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0.5,
      ),
      body: _loadingOrder
          ? const Center(child: CircularProgressIndicator())
          : _order == null
              ? Center(child: Text(context.t.tr('order_not_found')))
              : SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: Column(
                      children: [
                        _buildHeader(context),
                        SizedBox(height: 16),
                        _buildItemsSection(context),
                        SizedBox(height: 16),
                        _buildTotalCard(context),
                        SizedBox(height: 16),
                        _buildAddressCard(context),
                        SizedBox(height: 20),
                        if (_order!['driver_id'] != null && (_order!['driver_id'] as String).isNotEmpty)
                          _buildActionCard(context, Icons.chat_outlined, context.t.tr('chat_with_driver'), () => _showChatDialog(context)),
                        if (_order!['status'] == 'pending')
                          _buildActionCard(context, Icons.cancel_outlined, context.t.tr('cancel_order'), _cancelOrder, danger: true, loading: _cancelling),
                        if (_order!['status'] == 'delivered')
                          _buildRatingSection(context),
                        if ((_order!['payment_method'] as String? ?? 'cod') == 'card' ||
                            _order!['status'] == 'delivered')
                          _buildActionCard(context, Icons.download_outlined, context.t.tr('download_invoice'), () async {
                            try {
                              await WebInvoiceDownload().download(widget.orderId);
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Failed to download invoice: $e')),
                                );
                              }
                            }
                          }),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final status = _order!['status'] as String? ?? 'pending';
    final color = _statusColor(status);
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(_statusIcon(status), color: color, size: 28),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('#${_order!['id']}',
                        style: appStyle(20, FontWeight.w700, const Color(0xFF111827))),
                    SizedBox(height: 4),
                    Text(_formatDate(_order!['created_at'] as String?),
                        style: appStyle(14, FontWeight.w400, const Color(0xFF6B7280))),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(status[0].toUpperCase() + status.substring(1),
                    style: appStyle(13, FontWeight.w600, color)),
              ),
            ],
          ),
          if (_order!['order_code'] != null && (_order!['order_code'] as String).isNotEmpty) ...[
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.qr_code, size: 16, color: const Color(0xFF9CA3AF)),
                SizedBox(width: 6),
                Text('Code: ${_order!['order_code']}',
                    style: appStyle(13, FontWeight.w500, const Color(0xFF6B7280))),
              ],
            ),
          ],
        ],
      ),
    );
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return Icons.hourglass_empty;
      case 'shipped':
      case 'confirmed': return Icons.local_shipping;
      case 'in_transit': return Icons.delivery_dining;
      case 'delivered': return Icons.check_circle;
      case 'cancelled':
      case 'canceled': return Icons.cancel;
      default: return Icons.help_outline;
    }
  }

  Widget _buildItemsSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.t.tr('items'), style: appStyle(16, FontWeight.w600, const Color(0xFF111827))),
          SizedBox(height: 12),
          if (_loadingItems)
            ...List.generate(3, (_) => Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Row(children: [
                Container(width: 50, height: 50, decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(8),
                )),
                SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(height: 14, width: 100, decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(4))),
                  SizedBox(height: 6),
                  Container(height: 12, width: 60, decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(4))),
                ])),
              ]),
            ))
          else
            ..._items.map((item) {
              final product = item['products'] as Map<String, dynamic>?;
              final name = product?['name'] as String? ?? '';
              final price = (product?['price'] as num? ?? 0).toDouble();
              final qty = item['quantity'] as int? ?? 1;
              return Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 50, height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: product?['image'] != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(product!['image'], fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Icon(Icons.image, color: const Color(0xFF9CA3AF))),
                            )
                          : Icon(Icons.image, color: const Color(0xFF9CA3AF)),
                    ),
                    SizedBox(width: 12),
                    Expanded(child: Text(name, style: appStyle(14, FontWeight.w500, const Color(0xFF111827)))),
                    Text('x$qty', style: appStyle(13, FontWeight.w400, const Color(0xFF6B7280))),
                    SizedBox(width: 12),
                    Text('${context.t.tr('egp')} ${(price * qty).toStringAsFixed(0)}',
                        style: appStyle(14, FontWeight.w600, const Color(0xFF111827))),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildTotalCard(BuildContext context) {
    final total = _order!['total_price'] ?? 0;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(context.t.tr('total_amount'),
              style: appStyle(16, FontWeight.w600, const Color(0xFF111827))),
          Text('${context.t.tr('egp')} $total',
              style: appStyle(20, FontWeight.w700, AppColors.cta)),
        ],
      ),
    );
  }

  Widget _buildAddressCard(BuildContext context) {
    final address = _order!['delivery_address'] as String? ?? '';
    final phone = _order!['phone_number'] as String? ?? '';
    if (address.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 20, color: AppColors.primary),
              SizedBox(width: 8),
              Text(context.t.tr('delivery_address'),
                  style: appStyle(15, FontWeight.w600, const Color(0xFF111827))),
            ],
          ),
          SizedBox(height: 8),
          Text(address, style: appStyle(14, FontWeight.w400, const Color(0xFF6B7280))),
          if (phone.isNotEmpty) ...[
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.phone_outlined, size: 14, color: const Color(0xFF9CA3AF)),
                SizedBox(width: 6),
                Text(phone, style: appStyle(14, FontWeight.w400, const Color(0xFF6B7280))),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, IconData icon, String label, VoidCallback onTap,
      {bool danger = false, bool loading = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: HoverScale(
        onTap: loading ? null : onTap,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: danger ? AppColors.error.withValues(alpha: 0.3) : const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: [
              loading
                  ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : Icon(icon, color: danger ? AppColors.error : AppColors.primary, size: 22),
              SizedBox(width: 12),
              Text(label, style: appStyle(15, FontWeight.w500,
                  danger ? AppColors.error : const Color(0xFF111827))),
              const Spacer(),
              Icon(Icons.chevron_right, color: danger ? AppColors.error : const Color(0xFF9CA3AF), size: 22),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(context.t.tr('rate_driver'),
              style: appStyle(16, FontWeight.w600, const Color(0xFF111827))),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final star = i + 1;
              return IconButton(
                icon: Icon(
                  star <= _rating ? Icons.star : Icons.star_border,
                  color: star <= _rating ? const Color(0xFFF59E0B) : const Color(0xFFD1D5DB),
                  size: 36,
                ),
                onPressed: () => setState(() => _rating = star),
              );
            }),
          ),
          SizedBox(height: 8),
          SizedBox(
            width: double.infinity, height: 44,
            child: ElevatedButton(
              onPressed: _rating == 0 || _submittingRating ? null : _submitRating,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: _submittingRating
                  ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(context.t.tr('submit_rating'), style: appStyle(14, FontWeight.w600, Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

class _WebChatScreen extends StatefulWidget {
  final int orderId;
  final String driverId;
  const _WebChatScreen({required this.orderId, required this.driverId});

  @override
  State<_WebChatScreen> createState() => _WebChatScreenState();
}

class _WebChatScreenState extends State<_WebChatScreen> {
  final _ctrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  List<Map<String, dynamic>> _messages = [];
  bool _loading = true;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final data = await Supabase.instance.client
          .from('order_chat_messages')
          .select()
          .eq('order_id', widget.orderId)
          .order('created_at', ascending: true);
      if (mounted) setState(() { _messages = List<Map<String, dynamic>>.from(data); _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _sending = true);
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    try {
      await Supabase.instance.client.from('order_chat_messages').insert({
        'order_id': widget.orderId,
        'sender_id': userId,
        'sender_role': 'user',
        'message': text,
      });
      await Supabase.instance.client.from('notifications').insert({
        'user_id': widget.driverId,
        'title': 'New Message',
        'body': text,
        'type': jsonEncode({'type': 'order_chat', 'orderId': '${widget.orderId}', 'driverId': widget.driverId}),
        'read': false,
        'created_at': DateTime.now().toIso8601String(),
      });
      _ctrl.clear();
      await _load();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollCtrl.hasClients) {
          _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
        }
      });
    } catch (_) {}
    if (mounted) setState(() => _sending = false);
  }

  @override
  Widget build(BuildContext context) {
    final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
    return Scaffold(
      appBar: AppBar(
        title: Text('${context.t.tr('chat_with_driver')} - #${widget.orderId}'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0.5,
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? Center(child: Text(context.t.tr('no_messages_yet'), style: TextStyle(color: const Color(0xFF9CA3AF))))
                    : ListView.builder(
                        controller: _scrollCtrl,
                        padding: EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (_, i) {
                          final msg = _messages[i];
                          final isMine = msg['sender_id'] == userId;
                          return Align(
                            alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: EdgeInsets.only(bottom: 8),
                              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: isMine ? AppColors.primary : const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  topRight: Radius.circular(16),
                                  bottomLeft: isMine ? Radius.circular(16) : Radius.zero,
                                  bottomRight: isMine ? Radius.zero : Radius.circular(16),
                                ),
                              ),
                              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                              child: Text(
                                msg['message'] as String? ?? '',
                                style: TextStyle(color: isMine ? Colors.white : const Color(0xFF111827)),
                              ),
                            ),
                          );
                        },
                      ),
          ),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: Offset(0, -2))]),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    decoration: InputDecoration(
                      hintText: context.t.tr('type_message'),
                      filled: true,
                      fillColor: const Color(0xFFF3F4F6),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: _sending
                      ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Icon(Icons.send, color: AppColors.primary),
                  onPressed: _sending ? null : _send,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
