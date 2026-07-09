import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/widgets/app_style.dart';
import 'package:ship_link/web/presentation/shared/shimmer.dart';
import 'package:ship_link/web/presentation/shared/hover_widget.dart';
import 'package:ship_link/core/utils/sizer.dart';
import 'package:ship_link/web/data/models/favourite/favourite_model.dart';
import 'package:ship_link/web/presentation/cubits/favourite/favourite_cubit.dart';
import 'package:ship_link/web/presentation/cubits/addToCart/add_to_cart_cubit.dart';

class FavouriteWeb extends StatefulWidget {
  const FavouriteWeb({super.key});
  static String routName = '/favourites';

  @override
  State<FavouriteWeb> createState() => _FavouriteWebState();
}

class _FavouriteWebState extends State<FavouriteWeb> {
  @override
  void initState() {
    super.initState();
    context.read<FavouriteCubit>().getFavourites();
  }

  void _addToCart(int productId, String name) async {
    context.read<AddToCartCubit>().addToCart(id: productId, quantity: 1);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$name ${context.t.tr('added_to_cart')}')),
      );
    }
  }

  void _showProductDetail(BuildContext context, FavouriteItem item) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  item.productImage ?? '',
                  height: 250,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 250,
                    color: const Color(0xFFF3F4F6),
                    child: Icon(Icons.image, size: 48, color: const Color(0xFF9CA3AF)),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.productName ?? '',
                        style: appStyle(18, FontWeight.w600, const Color(0xFF111827))),
                    SizedBox(height: 8),
                    Text('${context.t.tr('egp')} ${(item.productPrice ?? 0).toStringAsFixed(0)}',
                        style: appStyle(22, FontWeight.w700, AppColors.cta)),
                    SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _addToCart(item.productId, item.productName ?? '');
                        },
                        icon: Icon(Icons.add_shopping_cart),
                        label: Text(context.t.tr('add_to_cart')),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<FavouriteCubit>().state;
    final loading = state is FavouriteLoading;
    final items = state is FavouriteLoaded ? state.items : <FavouriteItem>[];

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.tr('my_favourites')),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0.5,
      ),
      body: loading
          ? Padding(
              padding: EdgeInsets.all(16),
              child: ShimmerGrid(count: 4),
            )
          : items.isEmpty
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
                  itemCount: items.length,
                  itemBuilder: (_, i) {
                    final item = items[i];
                    final name = item.productName ?? '';
                    final price = (item.productPrice ?? 0).toDouble();
                    final image = item.productImage ?? '';
                    final productId = item.productId;
                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: Duration(milliseconds: 200 + (i * 60)),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) => Opacity(opacity: value, child: Transform.translate(
                        offset: Offset(0, 15 * (1 - value)), child: child,
                      )),
                      child: HoverScale(
                        onTap: () => _showProductDetail(context, item),
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
                                        onTap: () => context.read<FavouriteCubit>().toggleFavourite(productId),
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
                        onTap: () => _addToCart(productId, name),
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
