import 'package:flutter/material.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/widgets/app_style.dart';
import 'package:ship_link/web/presentation/screens/checkout/checkout_web.dart';
import 'package:ship_link/web/presentation/screens/login/login_web.dart';
import 'package:ship_link/web/presentation/shared/shimmer.dart';
import 'package:ship_link/core/utils/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CartWeb extends StatefulWidget {
  const CartWeb({super.key});
  static String routName = '/cart';

  @override
  State<CartWeb> createState() => _CartWebState();
}

class _CartWebState extends State<CartWeb> {
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) { if (mounted) setState(() => _loading = false); return; }
    try {
      final data = await Supabase.instance.client
          .from('cart_items')
          .select('*, products(*)')
          .eq('user_id', user.id);
      if (mounted) setState(() => _items = List<Map<String, dynamic>>.from(data));
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _remove(int id) async {
    await Supabase.instance.client.from('cart_items').delete().eq('id', id);
    _fetch();
  }

  double get _total {
    double t = 0;
    for (final item in _items) {
      final product = item['products'] as Map<String, dynamic>?;
      final price = (product?['price'] as num? ?? 0).toDouble();
      t += price * (item['quantity'] as int? ?? 1);
    }
    return t;
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.shopping_cart_outlined, size: 64, color: Color(0xFFD1D5DB)),
            SizedBox(height: 16.h),
            Text(context.t.tr('login_to_view_cart'),
                style: appStyle(16, FontWeight.w500, const Color(0xFF9CA3AF))),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, LoginWeb.routName),
              style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: Text(context.t.tr('sign_in')),
            ),
          ],
        ),
      );
    }

    if (_loading) {
      return ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: 3,
        itemBuilder: (_, __) => Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              ShimmerBox(width: 80, height: 80, radius: 12),
              SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(height: 16, width: 150),
                  SizedBox(height: 6),
                  ShimmerBox(height: 20, width: 80),
                ],
              )),
            ],
          ),
        ),
      );
    }

    if (_items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.shopping_cart_outlined, size: 64, color: Color(0xFFD1D5DB)),
            SizedBox(height: 16.h),
            Text(context.t.tr('cart_empty'),
                style: appStyle(16, FontWeight.w500, const Color(0xFF9CA3AF))),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: _items.length,
            itemBuilder: (context, i) => TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 300 + (i * 80)),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) => Opacity(opacity: value, child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)), child: child,
              )),
              child: _CartItemCard(item: _items[i], onRemove: () => _remove(_items[i]['id'] as int)),
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.t.tr('total_colon'),
                        style: appStyle(14, FontWeight.w400, const Color(0xFF6B7280))),
                    Text('${context.t.tr('egp')} ${_total.toStringAsFixed(0)}',
                        style: appStyle(24, FontWeight.w700, AppColors.cta)),
                  ],
                ),
              ),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, CheckoutWeb.routName),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cta,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Text(context.t.tr('checkout'),
                      style: appStyle(16, FontWeight.w600, Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onRemove;

  const _CartItemCard({required this.item, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final product = item['products'] as Map<String, dynamic>?;
    final name = product?['name'] as String? ?? '';
    final price = product?['price'] as num? ?? 0;
    final image = product?['image'] as String? ?? '';
    final qty = item['quantity'] as int? ?? 1;
    final currency = context.t.tr('egp');

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      color: const Color(0xFFFAFAFA),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: image.isNotEmpty
                  ? Image.network(image, width: 64, height: 64, fit: BoxFit.cover)
                  : Container(width: 64, height: 64, color: const Color(0xFFF0F0F0), child: const Icon(Icons.image, color: Color(0xFF9CA3AF))),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: appStyle(14, FontWeight.w600, const Color(0xFF111827)), maxLines: 1, overflow: TextOverflow.ellipsis),
                  SizedBox(height: 4),
                  Text('$currency ${price.toStringAsFixed(0)}', style: appStyle(15, FontWeight.w700, AppColors.cta)),
                  SizedBox(height: 2),
                  Text('${context.t.tr('qty')}: $qty', style: appStyle(12, FontWeight.w400, const Color(0xFF9CA3AF))),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 18, color: Color(0xFF9CA3AF)),
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}
