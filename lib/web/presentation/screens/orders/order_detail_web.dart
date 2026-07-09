import 'package:flutter/material.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/widgets/app_style.dart';
import 'package:ship_link/web/presentation/shared/hover_widget.dart';
import 'package:ship_link/web/presentation/shared/web_invoice_download.dart';
import 'package:ship_link/web/presentation/cubits/orderDetail/order_detail_cubit.dart';
import 'package:ship_link/web/presentation/screens/chat/order_chat_web.dart';
import 'package:ship_link/web/presentation/screens/tracking/tracking_web.dart';

class OrderDetailWeb extends StatefulWidget {
  final int orderId;
  const OrderDetailWeb({super.key, required this.orderId});
  static String routName = '/order-detail';

  @override
  State<OrderDetailWeb> createState() => _OrderDetailWebState();
}

class _OrderDetailWebState extends State<OrderDetailWeb> with SingleTickerProviderStateMixin {
  late final OrderDetailCubit _cubit;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  int _rating = 0;
  bool _submittingRating = false;
  bool _cancelling = false;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic);
    _cubit = OrderDetailCubit(orderId: widget.orderId);
    _cubit.stream.listen((state) {
      if (!mounted) return;
      if (state is OrderDetailLoaded) {
        _animCtrl.forward();
      }
    });
    _cubit.load();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _cubit.close();
    super.dispose();
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
    await _cubit.cancelOrder();
    if (mounted) {
      setState(() => _cancelling = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.t.tr('order_cancelled'))));
    }
  }

  Future<void> _submitRating() async {
    if (_rating == 0) return;
    setState(() => _submittingRating = true);
    await _cubit.submitRating(_rating);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.t.tr('rating_submitted'))));
      setState(() => _submittingRating = false);
    }
  }

  void _openOrderChat(BuildContext context) {
    final current = _cubit.state;
    if (current is! OrderDetailLoaded) return;
    final driverId = current.order['driver_id'] as String? ?? '';
    if (driverId.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrderChatWeb(orderId: widget.orderId, driverId: driverId),
      ),
    );
  }

  void _openTracking(BuildContext context) {
    final current = _cubit.state;
    if (current is! OrderDetailLoaded) return;
    final driverId = current.order['driver_id'] as String? ?? '';
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TrackingWeb(driverId: driverId.isEmpty ? null : driverId, orderId: widget.orderId),
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
      body: StreamBuilder<OrderDetailState>(
        stream: _cubit.stream,
        initialData: _cubit.state,
        builder: (context, snapshot) {
          final state = snapshot.data;
          if (state is OrderDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is OrderDetailError) {
            return Center(child: Text(state.message));
          }
          if (state is! OrderDetailLoaded) {
            return const Center(child: CircularProgressIndicator());
          }
          final order = state.order;
          final items = state.items;
          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                children: [
                  _buildHeader(context, order),
                  SizedBox(height: 16),
                  _buildItemsSection(context, items),
                  SizedBox(height: 16),
                  _buildTotalCard(context, order),
                  SizedBox(height: 16),
                  _buildAddressCard(context, order),
                  SizedBox(height: 20),
                  if (order['driver_id'] != null && (order['driver_id'] as String).isNotEmpty) ...[
                    _buildActionCard(context, Icons.chat_outlined, context.t.tr('chat_with_driver'), () => _openOrderChat(context)),
                    _buildActionCard(context, Icons.navigation_outlined, context.t.tr('live_tracking'), () => _openTracking(context)),
                  ],
                  if (order['status'] == 'pending')
                    _buildActionCard(context, Icons.cancel_outlined, context.t.tr('cancel_order'), _cancelOrder, danger: true, loading: _cancelling),
                  if (order['status'] == 'delivered')
                    _buildRatingSection(context),
                  if ((order['payment_method'] as String? ?? 'cod') == 'card' ||
                      order['status'] == 'delivered')
                    _buildActionCard(context, Icons.download_outlined, context.t.tr('download_invoice'), () async {
                      try {
                        await WebInvoiceDownload().download(widget.orderId);
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${context.t.tr('failed_download_invoice')}: $e')),
                          );
                        }
                      }
                    }),
                  SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Map<String, dynamic> order) {
    final status = order['status'] as String? ?? 'pending';
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
                    Text('#${order['id']}',
                        style: appStyle(20, FontWeight.w700, const Color(0xFF111827))),
                    SizedBox(height: 4),
                    Text(_formatDate(order['created_at'] as String?),
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
          if (order['order_code'] != null && (order['order_code'] as String).isNotEmpty) ...[
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.qr_code, size: 16, color: const Color(0xFF9CA3AF)),
                SizedBox(width: 6),
                Text('${context.t.tr('order_code')} ${order['order_code']}',
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

  Widget _buildItemsSection(BuildContext context, List<Map<String, dynamic>> items) {
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
          ...items.map((item) {
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

  Widget _buildTotalCard(BuildContext context, Map<String, dynamic> order) {
    final total = order['total_price'] ?? 0;
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

  Widget _buildAddressCard(BuildContext context, Map<String, dynamic> order) {
    final address = order['delivery_address'] as String? ?? '';
    final phone = order['phone_number'] as String? ?? '';
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


