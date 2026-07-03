import 'package:flutter/material.dart';
import 'package:ship_link/localization.dart';
import 'package:ship_link/constant/colors.dart';
import 'package:ship_link/views/shared/app_style.dart';
import 'package:ship_link/views/web/screens/checkout/congrats_web.dart';
import 'package:ship_link/views/web/shared/shimmer.dart';
import 'package:ship_link/views/web/shared/hover_widget.dart';
import 'package:ship_link/utils/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CheckoutWeb extends StatefulWidget {
  const CheckoutWeb({super.key});
  static String routName = '/checkout';

  @override
  State<CheckoutWeb> createState() => _CheckoutWebState();
}

class _CheckoutWebState extends State<CheckoutWeb> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _items = [];
  List<Map<String, dynamic>> _addresses = [];
  bool _loading = true;
  bool _placing = false;
  int _selectedMethod = 0;
  String? _selectedAddressId;

  final _phoneCtrl = TextEditingController();

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic);
    _fetch();
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetch() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    try {
      final itemsFuture = Supabase.instance.client
          .from('cart_items')
          .select('*, products(*)')
          .eq('user_id', user.id);

      final addressesFuture = Supabase.instance.client
          .from('user_addresses')
          .select('*')
          .eq('user_id', user.id)
          .order('is_default', ascending: false);

      final profileFuture = Supabase.instance.client
          .from('profiles')
          .select('phone_number')
          .eq('id', user.id)
          .maybeSingle();

      final results = await Future.wait([itemsFuture, addressesFuture, profileFuture]);
      final items = List<Map<String, dynamic>>.from(results[0] as List);
      final addresses = List<Map<String, dynamic>>.from(results[1] as List);
      final profile = results[2] as Map<String, dynamic>?;

      final defaultAddr = addresses.cast<Map<String, dynamic>?>().firstWhere(
        (a) => a?['is_default'] == true,
        orElse: () => addresses.isNotEmpty ? addresses.first : null,
      );

      if (mounted) {
        setState(() {
          _items = items;
          _addresses = addresses;
          _selectedAddressId = defaultAddr?['id'] as String?;
          _phoneCtrl.text = profile?['phone_number'] as String? ?? '';
        });
      }
    } catch (_) {}
    if (mounted) { setState(() => _loading = false); _animCtrl.forward(); }
  }

  Map<String, dynamic>? get _selectedAddress {
    if (_selectedAddressId == null) return null;
    try {
      return _addresses.firstWhere((a) => a['id'] == _selectedAddressId);
    } catch (_) {
      return null;
    }
  }

  double get _total {
    double t = 0;
    for (final item in _items) {
      final product = item['products'] as Map<String, dynamic>?;
      final price = (product?['price'] as num? ?? 0).toDouble();
      final qty = (item['quantity'] as int? ?? 1);
      t += price * qty;
    }
    return t;
  }

  Future<void> _placeOrder() async {
    setState(() => _placing = true);
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) return;
      final userEmail = user.email ?? '';

      await supabase.from('orders').insert({
        'user_id': user.id,
        'total_price': _total,
        'status': 'pending',
        'payment_method': _selectedMethod == 0 ? 'cod' : 'card',
        'delivery_address': _selectedAddress?.containsKey('full_address') == true
            ? (_selectedAddress!['full_address'] as String? ?? '')
            : '',
        'phone_number': _phoneCtrl.text,
        'created_at': DateTime.now().toIso8601String(),
      });

      await supabase.from('cart_items').delete().eq('user_id', user.id);

      if (mounted) {
        if (_selectedMethod == 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => CongratsWeb(userEmail: userEmail)),
          );
        } else {
          Navigator.pushNamedAndRemoveUntil(context, '/orders', (_) => false);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${context.t.tr('order_failed')}: $e')),
        );
      }
    }
    if (mounted) setState(() => _placing = false);
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text(context.t.tr('checkout'))),
        body: const Center(child: Text('Please login')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.tr('checkout')),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0.5,
      ),
      body: _loading
          ? Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(height: 24, width: 180),
                  SizedBox(height: 16),
                  ShimmerBox(height: 160),
                  SizedBox(height: 24),
                  ShimmerBox(height: 24, width: 160),
                  SizedBox(height: 12),
                  ShimmerBox(height: 72),
                  SizedBox(height: 10),
                  ShimmerBox(height: 72),
                  SizedBox(height: 24),
                  ShimmerBox(height: 52),
                ],
              ),
            )
          : FadeTransition(
              opacity: _fadeAnim,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDeliverySection(),
                    SizedBox(height: 24),
                    _buildOrderSummary(),
                    SizedBox(height: 24),
                    Text(context.t.tr('payment_method'),
                        style: appStyle(18, FontWeight.w600, const Color(0xFF111827))),
                    SizedBox(height: 12),
                    _paymentCard(0, Icons.money_rounded, context.t.tr('cash_on_delivery'),
                        context.t.tr('pay_when_receive')),
                    SizedBox(height: 10),
                    _paymentCard(1, Icons.credit_card_rounded, context.t.tr('pay_with_paymob'),
                        context.t.tr('pay_online_card')),
                    SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity, height: 52,
                      child: ElevatedButton(
                        onPressed: (_selectedAddress == null || _phoneCtrl.text.trim().isEmpty || _placing) ? null : _placeOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.cta,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: _placing
                            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : Text(context.t.tr('place_order'), style: appStyle(16, FontWeight.w600, Colors.white)),
                      ),
                    ),
                    SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDeliverySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(context.t.tr('delivery_details'),
                style: appStyle(20, FontWeight.w700, const Color(0xFF111827))),
            TextButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/addresses'),
              icon: Icon(Icons.add, size: 18),
              label: Text(context.t.tr('add_address')),
            ),
          ],
        ),
        SizedBox(height: 8),
        if (_addresses.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              children: [
                Icon(Icons.location_off_outlined, size: 48, color: const Color(0xFFD1D5DB)),
                SizedBox(height: 12),
                Text(context.t.tr('no_addresses'),
                    style: appStyle(15, FontWeight.w500, const Color(0xFF6B7280))),
              ],
            ),
          )
        else
          ...List.generate(_addresses.length, (i) {
            final addr = _addresses[i];
            final isSelected = addr['id'] == _selectedAddressId;
            final label = addr['label'] as String? ?? '';
            final city = addr['city'] as String? ?? '';
            final street = addr['street'] as String? ?? '';
            final full = addr['full_address'] as String? ?? '';
            final isDefault = addr['is_default'] == true;
            return Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: HoverScale(
                scale: 1.01,
                onTap: () => setState(() => _selectedAddressId = addr['id'] as String?),
                child: Container(
                  padding: EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : const Color(0xFFE5E7EB),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                        color: isSelected ? AppColors.primary : const Color(0xFFD1D5DB),
                        size: 22,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(label,
                                    style: appStyle(14, FontWeight.w600, const Color(0xFF111827))),
                                if (isDefault) ...[
                                  SizedBox(width: 8),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.cta.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(context.t.tr('default'),
                                        style: appStyle(11, FontWeight.w600, AppColors.cta)),
                                  ),
                                ],
                              ],
                            ),
                            if (city.isNotEmpty || street.isNotEmpty) ...[
                              SizedBox(height: 4),
                              Text([street, city].where((s) => s.isNotEmpty).join(', '),
                                  style: appStyle(13, FontWeight.w400, const Color(0xFF6B7280))),
                            ],
                            if (full.isNotEmpty) ...[
                              SizedBox(height: 2),
                              Text(full,
                                  maxLines: 2, overflow: TextOverflow.ellipsis,
                                  style: appStyle(12, FontWeight.w400, const Color(0xFF9CA3AF))),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        SizedBox(height: 16),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
          ),
          child: TextField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: context.t.tr('phone_number'),
              prefixIcon: const Icon(Icons.phone_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.receipt_long, color: AppColors.primary, size: 22),
              ),
              SizedBox(width: 12),
              Text(context.t.tr('order_summary'),
                  style: appStyle(16, FontWeight.w600, const Color(0xFF111827))),
            ],
          ),
          const Divider(height: 24),
          ...List.generate(_items.length, (i) {
            final product = _items[i]['products'] as Map<String, dynamic>?;
            final name = product?['name'] as String? ?? '';
            final price = (product?['price'] as num? ?? 0).toDouble();
            final qty = _items[i]['quantity'] as int? ?? 1;
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 300 + (i * 80)),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) => Opacity(opacity: value, child: child),
              child: Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Expanded(child: Text(name,
                        style: appStyle(14, FontWeight.w500, const Color(0xFF111827)))),
                    Text('x$qty',
                        style: appStyle(13, FontWeight.w400, const Color(0xFF6B7280))),
                    SizedBox(width: 16),
                    SizedBox(
                      width: 70,
                      child: Text('${context.t.tr('egp')} ${(price * qty).toStringAsFixed(0)}',
                          textAlign: TextAlign.right,
                          style: appStyle(14, FontWeight.w600, const Color(0xFF111827))),
                    ),
                  ],
                ),
              ),
            );
          }),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(context.t.tr('total_colon'),
                  style: appStyle(15, FontWeight.w600, const Color(0xFF111827))),
              Text('${context.t.tr('egp')} ${_total.toStringAsFixed(0)}',
                  style: appStyle(22, FontWeight.w700, AppColors.cta)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _paymentCard(int index, IconData icon, String title, String subtitle) {
    final isSelected = _selectedMethod == index;
    return HoverScale(
      scale: 1.01,
      onTap: () => setState(() => _selectedMethod = index),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: isSelected ? AppColors.primary : const Color(0xFF9CA3AF)),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: appStyle(15, FontWeight.w600, const Color(0xFF111827))),
                  SizedBox(height: 2),
                  Text(subtitle,
                      style: appStyle(13, FontWeight.w400, const Color(0xFF6B7280))),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? AppColors.primary : const Color(0xFFE5E7EB),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
