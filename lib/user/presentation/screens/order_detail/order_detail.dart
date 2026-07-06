import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/services/order_mute_service.dart';
import 'package:ship_link/core/services/pdf_invoice_service.dart';
import 'package:ship_link/core/services/supabase_service.dart';
import 'package:ship_link/core/widgets/snackBar/snack_bar.dart';
import 'package:ship_link/core/utils/sizer.dart';
import 'package:ship_link/core/widgets/app_style.dart';
import 'package:ship_link/core/widgets/shimmer/shimmer_loading.dart';
import 'package:ship_link/user/presentation/screens/chat/order_chat_screen.dart';
import 'package:ship_link/user/presentation/screens/tracking/driver_tracking_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ship_link/user/presentation/screens/cart/cart.dart';

class OrderDetail extends StatefulWidget {
  const OrderDetail({super.key, required this.orderId});
  static String routName = '/orderDetail';
  final int orderId;

  @override
  State<OrderDetail> createState() => _OrderDetailState();
}

class _OrderDetailState extends State<OrderDetail> {
  Future<Map<String, dynamic>?>? _orderFuture;
  Future<List<Map<String, dynamic>>>? _itemsFuture;
  final ValueNotifier<bool> _isMuted = ValueNotifier(false);
  final ValueNotifier<int> _refreshNotifier = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    _orderFuture = _loadOrder();
    _itemsFuture = _loadItems();
    _loadMuteStatus();
  }

  Future<void> _loadMuteStatus() async {
    final muted = await OrderMuteService().isMuted(widget.orderId.toString());
    if (mounted) { _isMuted.value = muted; _refreshNotifier.value++; }
  }

  Future<Map<String, dynamic>?> _loadOrder() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return null;
    final data = await Supabase.instance.client
        .from('orders')
        .select()
        .eq('id', widget.orderId)
        .eq('user_id', userId)
        .maybeSingle();
    return data;
  }

  Future<List<Map<String, dynamic>>> _loadItems() async {
    final items = await Supabase.instance.client
        .from('order_items')
        .select('product_id, quantity')
        .eq('order_id', widget.orderId);
    final List<Map<String, dynamic>> result = [];
    for (final item in items) {
      final pid = item['product_id'] as int?;
      if (pid == null) continue;
      final product = await Supabase.instance.client
          .from('products')
          .select()
          .eq('id', pid)
          .maybeSingle();
      result.add({
        'quantity': item['quantity'],
        'product_id': pid,
        'products': product,
      });
    }
    return result;
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':     return AppColors.warning;
      case 'shipped':
      case 'confirmed':   return AppColors.primary;
      case 'in_transit':  return AppColors.info;
      case 'delivered':   return AppColors.success;
      case 'cancelled':
      case 'canceled':    return AppColors.error;
      default:            return AppColors.textHint;
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':     return Icons.hourglass_empty;
      case 'shipped':
      case 'confirmed':   return Icons.local_shipping;
      case 'in_transit':  return Icons.delivery_dining;
      case 'delivered':   return Icons.check_circle;
      case 'cancelled':
      case 'canceled':    return Icons.cancel;
      default:            return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(context.t.tr('order_details'),
            style: appStyle(20, FontWeight.bold, AppColors.textPrimary)),
      ),
      body: ValueListenableBuilder<int>(
        valueListenable: _refreshNotifier,
        builder: (_, __, ___) => FutureBuilder<Map<String, dynamic>?>(
        future: _orderFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ShimmerLoading.productDetail();
          }
          final order = snapshot.data;
          if (order == null) {
            return Center(
              child: Text(context.t.tr('product_not_found'),
                  style: appStyle(16, FontWeight.w500, AppColors.textSecondary)),
            );
          }

          final id = order['id'] ?? 0;
          final total = order['total_price'] ?? 0;
          final status = order['status'] ?? 'pending';
          final orderCode = order['order_code'] ?? '';
          final createdAt = order['created_at'] ?? '';
          final date = createdAt is String && createdAt.length >= 10
              ? createdAt.substring(0, 10)
              : '';

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                _OrderHeader(
                  id: id,
                  date: date,
                  status: status,
                  statusColor: _statusColor(status.toString()),
                  statusIcon: _statusIcon(status.toString()),
                  orderCode: orderCode.toString(),
                ),
                const SizedBox(height: 16),
                _OrderTimeline(status: status.toString()),
                const SizedBox(height: 16),
                _ItemsSection(itemsFuture: _itemsFuture),
                const SizedBox(height: 16),
                _buildTotalCard(total),
                const SizedBox(height: 16),
                _buildAddressCard(order),
                _buildInstructionsCard(order),
                const SizedBox(height: 20),
                _buildTrackButton(order),
                if (order['driver_id'] != null &&
                    (order['driver_id'] as String).isNotEmpty)
                  _buildChatButton(order),
                if ((order['status'] as String? ?? '').toLowerCase() == 'pending')
                  _buildCancelButton(order),
                if ((order['status'] as String? ?? '').toLowerCase() == 'delivered') ...[
                  _buildDriverRating(order),
                  SizedBox(height: 8.h),
                  _buildReorderButton(order),
                ],
                if ((order['payment_method'] as String? ?? 'cod') == 'card' ||
                    (order['status'] as String? ?? '').toLowerCase() == 'delivered')
                  _buildInvoiceButton(order),
                _buildMuteButton(),
                _buildQrButton(order),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
      ),
    );
  }

  Widget _buildTotalCard(dynamic total) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(context.t.tr('total_amount'),
              style: appStyle(16, FontWeight.w600, AppColors.textPrimary)),
          Text('\$$total',
              style: appStyle(20, FontWeight.w700, AppColors.cta)),
        ],
      ),
    );
  }

  Widget _buildAddressCard(Map<String, dynamic> order) {
    final address = order['delivery_address'] as String? ?? '';
    final label = order['address_label'] as String? ?? '';
    final lat = (order['delivery_lat'] as num?)?.toDouble();
    final lng = (order['delivery_lng'] as num?)?.toDouble();
    if (address.isEmpty && label.isEmpty && lat == null) return const SizedBox.shrink();
    return GestureDetector(
      onTap: lat != null && lng != null
          ? () async {
              final uri = Uri.parse('https://www.google.com/maps?q=$lat,$lng');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            }
          : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(lat != null ? Icons.map : Icons.location_on_outlined,
                  color: AppColors.info, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (label.isNotEmpty)
                    Text(label,
                        style: appStyle(14, FontWeight.w600, AppColors.textPrimary)),
                  if (label.isNotEmpty && address.isNotEmpty)
                    const SizedBox(height: 2),
                  if (address.isNotEmpty)
                    Text(address,
                        style: appStyle(13, FontWeight.w400, AppColors.textSecondary)),
                  if (lat != null && lng != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text('View on Map →',
                          style: appStyle(12, FontWeight.w600, AppColors.primary)),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionsCard(Map<String, dynamic> order) {
    final instructions = order['delivery_instructions'] as String? ?? '';
    if (instructions.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7ED),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.notes_outlined, color: const Color(0xFFD97706), size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(context.t.tr('delivery_instructions'),
                      style: appStyle(14, FontWeight.w600, const Color(0xFF92400E))),
                  const SizedBox(height: 4),
                  Text(instructions,
                      style: appStyle(13, FontWeight.w400, const Color(0xFF92400E))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceButton(Map<String, dynamic> order) {
    final orderId = (order['id'] as num?)?.toInt() ?? 0;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () async {
            try {
              await PdfInvoiceService().share(orderId);
            } catch (e) {
              if (mounted) {
                CustomSnackBar.error('Invoice error: $e', context);
              }
            }
          },
          icon: const Icon(Icons.receipt_long),
          label: Text(context.t.tr('download_invoice')),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.cta,
            side: const BorderSide(color: AppColors.cta),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            padding: EdgeInsets.symmetric(vertical: 14.h),
          ),
        ),
      ),
    );
  }

  Widget _buildMuteButton() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () async {
            await OrderMuteService().toggle(widget.orderId.toString());
            if (mounted) { _isMuted.value = !_isMuted.value; _refreshNotifier.value++; }
            if (mounted) {
              CustomSnackBar.info(_isMuted.value
                  ? context.t.tr('notifications_muted_for_order')
                  : context.t.tr('notifications_unmuted_for_order'), context);
            }
          },
          icon: Icon(_isMuted.value ? Icons.notifications_off : Icons.notifications),
          label: Text(_isMuted.value
              ? context.t.tr('unmute_notifications')
              : context.t.tr('mute_notifications')),
          style: OutlinedButton.styleFrom(
            foregroundColor: _isMuted.value ? AppColors.error : AppColors.textSecondary,
            side: BorderSide(color: _isMuted.value ? AppColors.error : AppColors.border),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            padding: EdgeInsets.symmetric(vertical: 14.h),
          ),
        ),
      ),
    );
  }

  Widget _buildQrButton(Map<String, dynamic> order) {
    final orderId = (order['id'] as num?)?.toInt() ?? 0;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () => showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text('Order #$orderId',
                  textAlign: TextAlign.center,
                  style: appStyle(16, FontWeight.w600, AppColors.textPrimary)),
              content: Builder(
                builder: (ctx) {
                  final qrSize = MediaQuery.of(ctx).size.shortestSide * 0.5;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: qrSize,
                        height: qrSize,
                        child: QrImageView(
                          data: orderId.toString(),
                          version: QrVersions.auto,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(context.t.tr('show_qr_to_driver'),
                        textAlign: TextAlign.center,
                        style: appStyle(13, FontWeight.w400, AppColors.textSecondary)),
                    ],
                  );
                },
              ),
               actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(context.t.tr('close')),
                ),
              ],
            ),
          ),
          icon: const Icon(Icons.qr_code),
          label: Text(context.t.tr('show_order_qr')),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textPrimary,
            side: BorderSide(color: AppColors.border),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            padding: EdgeInsets.symmetric(vertical: 14.h),
          ),
        ),
      ),
    );
  }

  Widget _buildTrackButton(Map<String, dynamic> order) {
    final driverId = order['driver_id'] as String?;
    final status = (order['status'] as String? ?? '').toLowerCase();
    final hasDriver = driverId != null && driverId.isNotEmpty;
    final trackable = hasDriver && ['accepted', 'picked_up', 'shipped'].contains(status);
    if (!trackable) return const SizedBox.shrink();
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: () => Navigator.pushNamed(
          context,
          DriverTrackingScreen.routName,
          arguments: order['id'].toString(),
        ),
        icon: const Icon(Icons.navigation),
        label: Text(context.t.tr('track_shipment'),
            style: appStyle(16, FontWeight.w600, Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.cta,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
  Future<bool> _hasRatedDriver(int orderId) async {
    final data = await Supabase.instance.client
        .from('driver_ratings')
        .select('id')
        .eq('order_id', orderId)
        .maybeSingle();
    return data != null;
  }

  Widget _buildDriverRating(Map<String, dynamic> order) {
    final driverId = order['driver_id'] as String?;
    if (driverId == null || driverId.isEmpty) return const SizedBox.shrink();
    return FutureBuilder<bool>(
      future: _hasRatedDriver(order['id'] as int),
      builder: (context, snapshot) {
        if (snapshot.data == true) {
          return Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                  const Icon(Icons.star, color: AppColors.starFilled, size: 18),
                  const SizedBox(width: 6),
                Text(context.t.tr('driver_rated'),
                    style: appStyle(14, FontWeight.w500, AppColors.textSecondary)),
              ],
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.only(top: 12),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () => _showRateDriver(order),
              icon: const Icon(Icons.star, color: Colors.white, size: 18),
              label: Text(context.t.tr('rate_driver'),
                  style: appStyle(16, FontWeight.w600, Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            ),
          ),
        );
      },
    );
  }

  void _showRateDriver(Map<String, dynamic> order) {
    int rating = 5;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(context.t.tr('rate_driver'),
                      style: appStyle(20, FontWeight.w700, AppColors.textPrimary)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      final star = i + 1;
                      return IconButton(
                        icon: Icon(
                          star <= rating ? Icons.star : Icons.star_border,
                          color: AppColors.starFilled, size: 40,
                        ),
                        onPressed: () => setSheetState(() => rating = star),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await Supabase.instance.client.from('driver_ratings').insert({
                          'user_id': Supabase.instance.client.auth.currentUser?.id,
                          'driver_id': order['driver_id'],
                          'order_id': order['id'],
                          'rating': rating,
                        });
                        if (mounted) _refreshNotifier.value++;
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.cta),
                      child: Text(context.t.tr('submit'),
                          style: appStyle(16, FontWeight.w600, Colors.white)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildChatButton(Map<String, dynamic> order) {
    final driverId = order['driver_id'] as String? ?? '';
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton.icon(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OrderChatScreen(
                orderId: order['id'] as int,
                driverId: driverId,
              ),
            ),
          ),
          icon: const Icon(Icons.chat, color: Colors.white, size: 18),
          label: Text(context.t.tr('chat_with_driver'),
              style: appStyle(16, FontWeight.w600, Colors.white)),
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
        ),
      ),
    );
  }

  Widget _buildReorderButton(Map<String, dynamic> order) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: () => _reorderAll(order),
        icon: const Icon(Icons.replay, color: Colors.white, size: 18),
        label: Text(context.t.tr('reorder'),
            style: appStyle(16, FontWeight.w600, Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.success,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Future<void> _reorderAll(Map<String, dynamic> order) async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return;
    try {
      final items = await Supabase.instance.client
          .from('order_items')
          .select('product_id, quantity')
          .eq('order_id', order['id']);
      if (!mounted) return;
      if (items.isEmpty) {
        CustomSnackBar.info(context.t.tr('no_products_found'), context);
        return;
      }
      for (final item in items) {
        final existing = await Supabase.instance.client
            .from('cart_items')
            .select('id, quantity')
            .eq('user_id', uid)
            .eq('product_id', item['product_id'] as int)
            .maybeSingle();
        if (existing != null) {
          await Supabase.instance.client
              .from('cart_items')
              .update({'quantity': (existing['quantity'] as int? ?? 0) + (item['quantity'] as int? ?? 1)})
              .eq('id', existing['id'] as int);
        } else {
          int? cartId;
          final anyItem = await Supabase.instance.client
              .from('cart_items')
              .select('cart_id')
              .eq('user_id', uid)
              .limit(1)
              .maybeSingle();
          if (anyItem != null) cartId = anyItem['cart_id'] as int?;
          cartId ??= DateTime.now().millisecondsSinceEpoch;
          await Supabase.instance.client.from('cart_items').insert({
            'user_id': uid,
            'product_id': item['product_id'],
            'quantity': item['quantity'],
            'cart_id': cartId,
          });
        }
      }
      if (mounted) {
        CustomSnackBar.success(context.t.tr('items_added_to_cart'), context);
        Navigator.pushNamed(context, Cart.routName);
      }
    } catch (e) {
      if (mounted) CustomSnackBar.error('$e', context);
    }
  }

  Widget _buildCancelButton(Map<String, dynamic> order) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text(context.t.tr('cancel_order')),
              content: Text(context.t.tr('cancel_order_confirm')),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(context.t.tr('no')),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text(context.t.tr('yes'),
                      style: const TextStyle(color: AppColors.error)),
                ),
              ],
            ),
          );
          if (confirmed != true) return;
          await Supabase.instance.client
              .from('orders')
              .update({'status': 'cancelled'})
              .eq('id', order['id']);
          if (mounted) {
            _refreshNotifier.value++;
            CustomSnackBar.success(context.t.tr('order_cancelled'), context);
          }
        },
        icon: const Icon(Icons.cancel_outlined, color: AppColors.error),
        label: Text(context.t.tr('cancel_order'),
            style: appStyle(16, FontWeight.w600, AppColors.error)),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.error),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

class _OrderHeader extends StatelessWidget {
  final int id;
  final String date;
  final String status;
  final Color statusColor;
  final IconData statusIcon;
  final String orderCode;

  const _OrderHeader({
    required this.id,
    required this.date,
    required this.status,
    required this.statusColor,
    required this.statusIcon,
    required this.orderCode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${context.t.tr('order_no')} #$id',
                  style: appStyle(18, FontWeight.w700, AppColors.textPrimary)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 16, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      context.t.tr(status),
                      style: appStyle(13, FontWeight.w600, statusColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24, color: AppColors.border),
          _infoRow(context, context.t.tr('order_date'), date),
          if (orderCode.isNotEmpty)
            _infoRow(context, context.t.tr('order_code'), orderCode),
        ],
      ),
    );
  }

  Widget _infoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: appStyle(14, FontWeight.w500, AppColors.textSecondary)),
          Text(value,
              style: appStyle(14, FontWeight.w600, AppColors.textPrimary)),
        ],
      ),
    );
  }
}

class _OrderTimeline extends StatelessWidget {
  final String status;

  const _OrderTimeline({required this.status});

  @override
  Widget build(BuildContext context) {
    final steps = [
      _TimelineStep('pending', Icons.receipt, context.t.tr('order_placed')),
      _TimelineStep('confirmed', Icons.check_circle, context.t.tr('confirmed')),
      _TimelineStep('shipped', Icons.local_shipping, context.t.tr('shipped')),
      _TimelineStep('in_transit', Icons.delivery_dining, context.t.tr('out_for_delivery')),
      _TimelineStep('delivered', Icons.check_circle, context.t.tr('delivered')),
    ];

    final isCancelled = status.toLowerCase() == 'cancelled' || status.toLowerCase() == 'canceled';
    final currentIdx = isCancelled
        ? steps.indexWhere((s) => s.key == status.toLowerCase())
        : steps.indexWhere((s) => s.key == status.toLowerCase());

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.t.tr('order_progress'),
              style: appStyle(15, FontWeight.w600, AppColors.textPrimary)),
          SizedBox(height: 16.h),
          ...List.generate(steps.length, (i) {
            final step = steps[i];
            final isCompleted = currentIdx >= i && i < steps.length && !isCancelled;
            final isCurrent = i == currentIdx && !isCancelled;
            final isCancelledStep = isCancelled && i == currentIdx;
            final isFutureStep = i > currentIdx;

            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 32,
                    child: Column(
                      children: [
                        Container(
                          width: isCurrent ? 14 : 10,
                          height: isCurrent ? 14 : 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCancelledStep
                                ? AppColors.error
                                : isCompleted
                                    ? AppColors.success
                                    : isCurrent
                                        ? AppColors.primary
                                        : AppColors.border,
                          ),
                          child: isCompleted
                              ? Icon(Icons.check, size: 8, color: Colors.white)
                              : null,
                        ),
                        if (i < steps.length - 1)
                          Expanded(
                            child: Container(
                              width: 2,
                              color: isCancelledStep
                                  ? AppColors.error.withValues(alpha: 0.3)
                                  : isCompleted
                                      ? AppColors.success.withValues(alpha: 0.5)
                                      : AppColors.border,
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Padding(
                    padding: EdgeInsets.only(bottom: i < steps.length - 1 ? 16.h : 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(step.label,
                            style: appStyle(
                              13,
                              isCurrent || isCompleted
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              isCancelledStep
                                  ? AppColors.error
                                  : isCompleted
                                      ? AppColors.success
                                      : isCurrent
                                          ? AppColors.textPrimary
                                          : AppColors.textDisabled,
                            )),
                        if (isCurrent || isCancelledStep)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              isCancelledStep
                                  ? context.t.tr('order_cancelled')
                                  : context.t.tr('current_status'),
                              style: appStyle(11, FontWeight.w400, AppColors.textHint),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _TimelineStep {
  final String key;
  final IconData icon;
  final String label;
  const _TimelineStep(this.key, this.icon, this.label);
}

class _ItemsSection extends StatelessWidget {
  final Future<List<Map<String, dynamic>>>? itemsFuture;

  const _ItemsSection({this.itemsFuture});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: itemsFuture,
      builder: (context, snapshot) {
        final items = snapshot.data ?? [];
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ShimmerLoading.orderHistory(itemCount: 3);
        }
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.t.tr('items'),
                  style: appStyle(16, FontWeight.w700, AppColors.textPrimary)),
              const SizedBox(height: 12),
              if (items.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Text(context.t.tr('no_products_found'),
                        style: appStyle(14, FontWeight.w400,
                            AppColors.textHint)),
                  ),
                )
              else
                ...items.map((item) {
                  final product = item['products'] as Map<String, dynamic>?;
                  final name = product?['name'] ?? 'Product';
                  final price = product?['price'] ?? 0;
                  final qty = item['quantity'] ?? 1;
                  final image = product?['image'];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: image != null && image.toString().isNotEmpty
                              ? Image.network(
                                  image.toString(),
                                  width: 56,
                                  height: 56,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      _placeholderImage(),
                                )
                              : _placeholderImage(),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name,
                                  style: appStyle(14, FontWeight.w600,
                                      AppColors.textPrimary),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 4),
                              Text('${context.t.tr('quantity')}: $qty',
                                  style: appStyle(12, FontWeight.w400,
                                      AppColors.textHint)),
                            ],
                          ),
                        ),
                        Text('\$${(price as num?)?.toDouble() ?? 0}',
                            style: appStyle(
                                14, FontWeight.w700, AppColors.textPrimary)),
                      ],
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }

  Widget _placeholderImage() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.image, color: AppColors.textHint),
    );
  }
}
