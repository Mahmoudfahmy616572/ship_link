import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/widgets/app_style.dart';
import 'package:ship_link/web/presentation/screens/checkout/checkout_web.dart';
import 'package:ship_link/web/presentation/screens/welcome/welcome_web.dart';
import 'package:ship_link/web/presentation/shared/shimmer.dart';
import 'package:ship_link/web/presentation/services/web_cache_service.dart';
import 'package:ship_link/core/utils/sizer.dart';
import 'package:ship_link/web/data/models/getFromCart/get_from_cart.dart';
import 'package:ship_link/web/presentation/cubits/getFromCart/get_from_cart_cubit.dart';
import 'package:ship_link/web/presentation/cubits/addToCart/add_to_cart_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CartWeb extends StatefulWidget {
  const CartWeb({super.key});
  static String routName = '/cart';

  @override
  State<CartWeb> createState() => _CartWebState();
}

class _CartWebState extends State<CartWeb> {
  List<Map<String, dynamic>> _savedItems = [];
  bool _savedLoaded = false;

  @override
  void initState() {
    super.initState();
    context.read<GetFromCartCubit>().getProductFromCart();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final raw = await WebCacheService().get('saved_for_later');
    if (raw != null && mounted) {
      setState(() {
        _savedItems = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
        _savedLoaded = true;
      });
    } else if (mounted) {
      setState(() => _savedLoaded = true);
    }
  }

  Future<void> _saveSaved() async {
    await WebCacheService().put('saved_for_later', jsonEncode(_savedItems));
  }

  void _saveForLater(Detail item) {
    final product = item.product;
    if (product == null) return;
    final saved = {
      'id': product.id,
      'name': product.name,
      'price': product.price,
      'image': product.image,
    };
    setState(() => _savedItems.add(saved));
    _saveSaved();
    context.read<GetFromCartCubit>().deleteFromCart(
      cart_id: item.id ?? 0,
      product_id: product.id ?? 0,
    );
  }

  void _removeSaved(int index) {
    setState(() => _savedItems.removeAt(index));
    _saveSaved();
  }

  void _moveToCart(Map<String, dynamic> item, int index) {
    final productId = item['id'] as int?;
    if (productId == null) return;
    context.read<AddToCartCubit>().addToCart(id: productId, quantity: 1);
    setState(() => _savedItems.removeAt(index));
    _saveSaved();
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
              onPressed: () => Navigator.pushNamed(context, WelcomeWeb.routName),
              style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: Text(context.t.tr('sign_in')),
            ),
          ],
        ),
      );
    }

    final state = context.watch<GetFromCartCubit>().state;

    if (state is GetFromCartLoading) {
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

    final items = state is GetFromCartSuccess ? (state.getProductFromCart.details ?? []) : <Detail>[];

    if (items.isEmpty) {
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

    final total = items.fold<double>(0, (sum, item) {
      final price = (item.product?.price ?? 0).toDouble();
      return sum + price * (item.qty ?? 1);
    });

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.all(16),
            children: [
              ...List.generate(items.length, (i) => TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 300 + (i * 80)),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) => Opacity(opacity: value, child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)), child: child,
                )),
                child: _CartItemCard(
                  item: items[i],
                  onRemove: () => context.read<GetFromCartCubit>().deleteFromCart(
                    cart_id: items[i].id ?? 0,
                    product_id: items[i].product?.id ?? 0,
                  ),
                  onSaveForLater: () => _saveForLater(items[i]),
                ),
              )),
              if (_savedItems.isNotEmpty) ...[
                SizedBox(height: 20),
                Text(context.t.tr('saved_for_later'), style: appStyle(16, FontWeight.w700, const Color(0xFF111827))),
                SizedBox(height: 8),
                ...List.generate(_savedItems.length, (i) {
                  final saved = _savedItems[i];
                  final name = saved['name'] ?? '';
                  final price = (saved['price'] ?? 0).toDouble();
                  final image = saved['image'] ?? '';
                  final currency = context.t.tr('egp');
                  return Card(
                    margin: EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                    color: const Color(0xFFFFFBEB),
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: image.isNotEmpty
                                ? Image.network(image, width: 56, height: 56, fit: BoxFit.cover)
                                : Container(width: 56, height: 56, color: const Color(0xFFF0F0F0), child: const Icon(Icons.image, color: Color(0xFF9CA3AF))),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name, style: appStyle(13, FontWeight.w600, const Color(0xFF111827)), maxLines: 1, overflow: TextOverflow.ellipsis),
                                SizedBox(height: 4),
                                Text('$currency ${price.toStringAsFixed(0)}', style: appStyle(14, FontWeight.w700, AppColors.cta)),
                              ],
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () => _moveToCart(saved, i),
                            icon: Icon(Icons.shopping_cart_outlined, size: 16, color: AppColors.primary),
                            label: Text(context.t.tr('add_to_cart'), style: appStyle(12, FontWeight.w500, AppColors.primary)),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 16, color: Color(0xFF9CA3AF)),
                            onPressed: () => _removeSaved(i),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ],
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
                    Text('${context.t.tr('egp')} ${total.toStringAsFixed(0)}',
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
  final Detail item;
  final VoidCallback onRemove;
  final VoidCallback? onSaveForLater;

  const _CartItemCard({required this.item, required this.onRemove, this.onSaveForLater});

  @override
  Widget build(BuildContext context) {
    final product = item.product;
    final name = product?.name ?? '';
    final price = product?.price ?? 0;
    final image = product?.image ?? '';
    final qty = item.qty ?? 1;
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
              icon: const Icon(Icons.bookmark_border, size: 18, color: Color(0xFFF59E0B)),
              onPressed: onSaveForLater,
              tooltip: 'Save for later',
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
