import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/utils/sizer.dart';
import 'package:ship_link/constant/colors.dart';
import 'package:ship_link/constant/services_locators.dart';
import 'package:ship_link/cubits/getFromCart/get_from_cart_cubit.dart';
import 'package:share_plus/share_plus.dart';
import 'package:ship_link/data/models/allProducts/all_products.dart' as allProducts;
import 'package:ship_link/data/services/cartServeices/cart_serveicesimpl.dart';
import 'package:ship_link/views/shared/app_style.dart';
import 'package:ship_link/views/shared/shimmer/shimmer_loading.dart';
import 'package:ship_link/views/user/screens/cart/components/bottom_nav_bar.dart';
import 'package:ship_link/localization.dart';
import 'package:ship_link/views/user/screens/MainScreen/main_screen.dart';
import 'package:ship_link/views/user/screens/product/product_screen.dart';

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  List<Map<String, dynamic>> _suggestions = [];
  bool _loadingSuggestions = false;

  void _loadSuggestions(List<dynamic> details) {
    if (details.isEmpty) return;
    final categories = <String>{};
    final excludeIds = <int>[];
    for (final d in details) {
      final cat = d.product?.category;
      if (cat != null && cat.isNotEmpty) categories.add(cat);
      final pid = d.product?.id;
      if (pid != null) excludeIds.add(pid);
    }
    if (categories.isEmpty) return;
    setState(() => _loadingSuggestions = true);
    getIt<CartServeicesImpl>().getSuggestedProducts(categories.toList(), excludeIds: excludeIds).then((result) {
      if (!mounted) return;
      result.fold(
        (_) => setState(() { _suggestions = []; _loadingSuggestions = false; }),
        (data) => setState(() { _suggestions = data; _loadingSuggestions = false; }),
      );
    });
  }

  @override
  void initState() {
    super.initState();
    context.read<GetFromCartCubit>().getProductFromCart();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GetFromCartCubit, GetFromCartState>(
      listener: (context, state) {
        if (state is DeleteFromCartSuccess) {
          context.read<GetFromCartCubit>().getProductFromCart();
        }
        if (state is GetFromCartSuccess) {
          final details = state.getProductFromCart.details ?? [];
          if (_suggestions.isEmpty && details.isNotEmpty) {
            _loadSuggestions(details);
          }
        }
      },
      builder: (context, state) {
        if (state is GetFromCartLoading) {
          return ShimmerLoading.list();
        } else if (state is GetFromCartFailure) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_cart_outlined,
                    size: 80.sp, color: AppColors.textHint),
                SizedBox(height: 16.h),
                Text(context.t.tr('your_cart_is_empty'),
                    style: appStyle(
                        18, FontWeight.w600, AppColors.textPrimary)),
                SizedBox(height: 8.h),
                Text(state.errMessage,
                    style: appStyle(
                        14, FontWeight.normal, AppColors.textSecondary)),
                SizedBox(height: 20.h),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(
                      context, MainScreen.routName, (route) => false),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white),
                  child: Text(context.t.tr('start_shopping')),
                ),
              ],
            ),
          );
        } else if (state is GetFromCartSuccess) {
          final details = state.getProductFromCart.details ?? [];
          if (details.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined,
                      size: 80.sp, color: Colors.grey[400]),
                  SizedBox(height: 16.h),
                  Text(context.t.tr('your_cart_is_empty'),
                      style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600])),
                  SizedBox(height: 8.h),
                  Text(context.t.tr('not_added_anything'),
                      style: TextStyle(fontSize: 14.sp, color: Colors.grey[500])),
                  SizedBox(height: 20.h),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(
                        context, MainScreen.routName, (route) => false),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white),
                    child: Text(context.t.tr('start_shopping')),
                  ),
                ],
              ),
            );
          }
          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  itemCount: details.length + (_suggestions.isNotEmpty ? 1 : 0),
                  separatorBuilder: (_, __) => Divider(height: 1.h, color: AppColors.border),
                  itemBuilder: (context, index) {
                    if (index == details.length) {
                      return _buildSuggestions();
                    }
                    final detail = details[index];
                    return Dismissible(
                      key: ValueKey(detail.id ?? index),
                      direction: DismissDirection.horizontal,
                      background: Container(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.only(left: 20.w),
                        decoration: BoxDecoration(
                          color: AppColors.info,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(Icons.share, color: Colors.white, size: 28.sp),
                      ),
                      secondaryBackground: Container(
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(right: 20.w),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(Icons.delete, color: Colors.white, size: 28.sp),
                      ),
                      confirmDismiss: (direction) async {
                        if (direction == DismissDirection.endToStart) {
                          return true;
                        }
                        if (direction == DismissDirection.startToEnd) {
                          final name = detail.product?.name ?? '';
                          final price = detail.product?.price?.toStringAsFixed(2) ?? '';
                          SharePlus.instance.share(ShareParams(
                            text: 'Check out $name on ShipLink for \$$price!',
                          ));
                          return false;
                        }
                        return false;
                      },
                      onDismissed: (_) {
                        final itemId = detail.id;
                        final prodId = detail.product?.id;
                        if (itemId != null && prodId != null) {
                          context
                              .read<GetFromCartCubit>()
                              .deleteFromCart(cart_id: itemId, product_id: prodId);
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${detail.product?.name ?? context.t.tr("item_removed_from_cart")} removed from cart',
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10.r),
                              child: CachedNetworkImage(
                                imageUrl: detail.product?.image ?? "",
                                width: 80.w,
                                height: 80.h,
                                fit: BoxFit.cover,
                                errorWidget: (_, __, ___) => Container(
                                  width: 80.w,
                                  height: 80.h,
                                  color: AppColors.surface,
                                  child: const Icon(Icons.image, color: AppColors.textHint),
                                ),
                              ),
                            ),
                            SizedBox(width: 14.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    detail.product?.name ?? "Product",
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: appStyle(15, FontWeight.w500, AppColors.textPrimary),
                                  ),
                                  SizedBox(height: 6.h),
                                  Text(
                                    "\$${detail.product?.price?.toStringAsFixed(2) ?? "0.00"}",
                                    style: appStyle(16, FontWeight.w700, AppColors.cta),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              ButtomNavBar(),
            ],
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildSuggestions() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Text(
              context.t.tr('you_may_also_like'),
              style: appStyle(18, FontWeight.w700, AppColors.textPrimary),
            ),
          ),
          SizedBox(height: 10.h),
          if (_loadingSuggestions)
            SizedBox(
              height: 180.h,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else if (_suggestions.isEmpty)
            const SizedBox.shrink()
          else
            SizedBox(
              height: 200.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: _suggestions.length,
                separatorBuilder: (_, __) => SizedBox(width: 10.w),
                itemBuilder: (context, index) {
                  final item = _suggestions[index];
                  return GestureDetector(
                    onTap: () {
                      final p = allProducts.Product(
                        id: item['id'],
                        name: item['name'],
                        image: item['image'],
                        price: (item['price'] as num?)?.toDouble(),
                        category: item['category'],
                      );
                      Navigator.push(context, MaterialPageRoute(builder: (_) => ProductScreen(product: p)));
                    },
                    child: Container(
                      width: 140.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
                            child: CachedNetworkImage(
                              imageUrl: item['image'] ?? '',
                              height: 110.h,
                              width: 140.w,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) => Container(
                                height: 110.h,
                                color: AppColors.surface,
                                child: Icon(Icons.image, color: AppColors.textHint),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['name'] ?? '',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: appStyle(13, FontWeight.w500, AppColors.textPrimary),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  "\$${(item['price'] as num?)?.toStringAsFixed(2) ?? '0.00'}",
                                  style: appStyle(14, FontWeight.w700, AppColors.cta),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
