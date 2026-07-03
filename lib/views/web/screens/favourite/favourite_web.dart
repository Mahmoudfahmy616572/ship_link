import 'package:flutter/material.dart';
import 'package:ship_link/localization.dart';
import 'package:ship_link/constant/colors.dart';
import 'package:ship_link/views/shared/app_style.dart';
import 'package:ship_link/views/web/shared/shimmer.dart';
import 'package:ship_link/views/web/shared/hover_widget.dart';
import 'package:ship_link/utils/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FavouriteWeb extends StatefulWidget {
  const FavouriteWeb({super.key});
  static String routName = '/favourites';

  @override
  State<FavouriteWeb> createState() => _FavouriteWebState();
}

class _FavouriteWebState extends State<FavouriteWeb> {
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    try {
      final data = await Supabase.instance.client
          .from('favourites')
          .select('*, products(*)')
          .eq('user_id', user.id);
      if (mounted) setState(() => _items = List<Map<String, dynamic>>.from(data));
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _remove(int productId) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    await Supabase.instance.client
        .from('favourites')
        .delete()
        .eq('user_id', user.id)
        .eq('product_id', productId);
    _load();
  }

  Future<void> _addToCart(Map<String, dynamic> product) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    final existing = await Supabase.instance.client
        .from('cart_items')
        .select('id, quantity')
        .eq('user_id', user.id)
        .eq('product_id', product['id'])
        .maybeSingle();
    if (existing != null) {
      await Supabase.instance.client.from('cart_items')
          .update({'quantity': (existing['quantity'] as int) + 1})
          .eq('id', existing['id']);
    } else {
      await Supabase.instance.client.from('cart_items').insert({
        'user_id': user.id, 'product_id': product['id'], 'quantity': 1,
      });
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${product['name']} ${context.t.tr('added_to_cart')}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.tr('my_favourites')),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0.5,
      ),
      body: _loading
          ? Padding(
              padding: EdgeInsets.all(16),
              child: ShimmerGrid(count: 4),
            )
          : _items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.favorite_border, size: 64, color: const Color(0xFFD1D5DB)),
                      SizedBox(height: 16),
                      Text(context.t.tr('no_favourites_yet'),
                          style: appStyle(16, FontWeight.w500, const Color(0xFF9CA3AF))),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _items.length,
                  itemBuilder: (_, i) {
                    final item = _items[i];
                    final product = item['products'] as Map<String, dynamic>? ?? {};
                    final name = product['name'] as String? ?? '';
                    final price = (product['price'] as num? ?? 0).toDouble();
                    final image = product['image'] as String? ?? '';
                    final productId = product['id'] as int? ?? 0;
                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: Duration(milliseconds: 200 + (i * 60)),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) => Opacity(opacity: value, child: Transform.translate(
                        offset: Offset(0, 15 * (1 - value)), child: child,
                      )),
                      child: HoverScale(
                        child: Card(
                          elevation: 0,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                                      child: Image.network(image, width: double.infinity, fit: BoxFit.cover,
                                          loadingBuilder: (_, c, p) => p == null ? c : Container(color: const Color(0xFFF3F4F6)),
                                          errorBuilder: (_, __, ___) => Container(color: const Color(0xFFF3F4F6), child: Icon(Icons.image, color: const Color(0xFF9CA3AF)))),
                                    ),
                                    Positioned(
                                      top: 4, right: 4,
                                      child: HoverScale(
                                        onTap: () => _remove(productId),
                                        child: Container(
                                          padding: EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)],
                                          ),
                                          child: Icon(Icons.close, size: 16, color: AppColors.error),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(name, style: appStyle(13, FontWeight.w500, const Color(0xFF111827)), maxLines: 2, overflow: TextOverflow.ellipsis),
                                    SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text('${context.t.tr('egp')} ${price.toStringAsFixed(0)}',
                                            style: appStyle(15, FontWeight.w700, AppColors.cta)),
                                        const Spacer(),
                                        SizedBox(
                                          height: 32, width: 32,
                                          child: HoverScale(
                                            onTap: () => _addToCart(product),
                                            child: Container(
                                              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
                                              child: Icon(Icons.add_shopping_cart, color: Colors.white, size: 16),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
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
