import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/core/utils/sizer.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/widgets/snackBar/snack_bar.dart';
import 'package:ship_link/core/constants/services_locators.dart';
import 'package:ship_link/user/presentation/cubits/getFromCart/get_from_cart_cubit.dart';
import 'package:share_plus/share_plus.dart';
import 'package:ship_link/user/data/models/allProducts/all_products.dart' as allProducts;
import 'package:ship_link/user/domain/repositories/cart_repository.dart';
import 'package:ship_link/core/widgets/app_style.dart';
import 'package:ship_link/core/widgets/shimmer/shimmer_loading.dart';
import 'package:ship_link/user/presentation/screens/cart/components/bottom_nav_bar.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/user/presentation/screens/MainScreen/main_screen.dart';
import 'package:ship_link/user/presentation/screens/product/product_screen.dart';
import 'package:ship_link/core/services/cache_service.dart';

class Body extends StatefulWidget {
  final ScrollController? scrollController;
  const Body({super.key, this.scrollController});

  @override
  State<Body> createState() => _BodyState();
}

class _CartBodyState {
  final List<Map<String, dynamic>> savedItems;
  final List<Map<String, dynamic>> suggestions;
  final bool loadingSuggestions;
  final bool savedExpanded;

  const _CartBodyState({
    this.savedItems = const [],
    this.suggestions = const [],
    this.loadingSuggestions = false,
    this.savedExpanded = true,
  });

  _CartBodyState copyWith({
    List<Map<String, dynamic>>? savedItems,
    List<Map<String, dynamic>>? suggestions,
    bool? loadingSuggestions,
    bool? savedExpanded,
  }) {
    return _CartBodyState(
      savedItems: savedItems ?? this.savedItems,
      suggestions: suggestions ?? this.suggestions,
      loadingSuggestions: loadingSuggestions ?? this.loadingSuggestions,
      savedExpanded: savedExpanded ?? this.savedExpanded,
    );
  }
}

class _BodyState extends State<Body> {
  final _state = ValueNotifier<_CartBodyState>(_CartBodyState());

  @override
  void initState() {
    super.initState();
    _loadSaved();
    context.read<GetFromCartCubit>().getProductFromCart();
  }

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  Future<void> _loadSaved() async {
    final data = await CacheService().get('saved_for_later');
    if (data != null && mounted) {
      _state.value = _state.value.copyWith(
        savedItems: (data as List).cast<Map<String, dynamic>>(),
      );
    }
  }

  Future<void> _saveItem(int? id, String? name, String? image, double? price) async {
    if (id == null) return;
    final current = _state.value.savedItems;
    if (current.any((e) => e['id'] == id)) return;
    final updated = [
      ...current,
      {'id': id, 'name': name, 'image': image, 'price': price},
    ];
    await CacheService().put('saved_for_later', updated, ttl: const Duration(days: 365));
    if (mounted) _state.value = _state.value.copyWith(savedItems: updated);
  }

  Future<void> _removeSaved(int productId) async {
    final updated = _state.value.savedItems.where((e) => e['id'] != productId).toList();
    await CacheService().put('saved_for_later', updated, ttl: const Duration(days: 365));
    if (mounted) _state.value = _state.value.copyWith(savedItems: updated);
  }

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
    _state.value = _state.value.copyWith(loadingSuggestions: true);
    getIt<CartRepository>().getSuggestedProducts(categories.toList(), excludeIds: excludeIds).then((result) {
      if (!mounted) return;
      result.fold(
        (_) => _state.value = _state.value.copyWith(suggestions: [], loadingSuggestions: false),
        (data) => _state.value = _state.value.copyWith(suggestions: data, loadingSuggestions: false),
      );
    });
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
          if (_state.value.suggestions.isEmpty && details.isNotEmpty) {
            _loadSuggestions(details);
          }
        }
      },
      builder: (context, state) {
        if (state is GetFromCartLoading || state is DeleteFromCartLoading) {
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
            return ValueListenableBuilder<_CartBodyState>(
              valueListenable: _state,
              builder: (context, cartState, _) {
                if (cartState.savedItems.isEmpty) {
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
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
                        child: Column(
                          children: [
                            Icon(Icons.shopping_cart_outlined,
                                size: 60.sp, color: Colors.grey[400]),
                            SizedBox(height: 12.h),
                            Text(context.t.tr('your_cart_is_empty'),
                                style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[600])),
                            SizedBox(height: 4.h),
                            Text(context.t.tr('not_added_anything'),
                                style: TextStyle(fontSize: 13.sp, color: Colors.grey[500])),
                            SizedBox(height: 16.h),
                            _buildSavedItems(),
                          ],
                        ),
                      ),
                    ),
                    ButtomNavBar(),
                  ],
                );
              },
            );
          }
          return ValueListenableBuilder<_CartBodyState>(
            valueListenable: _state,
            builder: (context, cartState, child) {
              return Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      controller: widget.scrollController,
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      itemCount: details.length + (cartState.savedItems.isNotEmpty ? 1 : 0) + (cartState.suggestions.isNotEmpty ? 1 : 0),
                      separatorBuilder: (_, __) => Divider(height: 1.h, color: AppColors.border),
                      itemBuilder: (context, index) {
                        int offset = 0;
                        if (index == details.length + offset) {
                          return cartState.savedItems.isNotEmpty ? _buildSavedItems() : const SizedBox.shrink();
                        }
                        if (cartState.savedItems.isNotEmpty) offset++;
                        if (index == details.length + offset) {
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
                              final id = detail.product?.id ?? 0;
                              final name = detail.product?.name ?? '';
                              final link = 'https://shiplink.app/product/$id';
                              SharePlus.instance.share(ShareParams(
                                text: 'Check out $name on ShipLink!\n$link',
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
                            CustomSnackBar.info('${detail.product?.name ?? context.t.tr("item_removed_from_cart")} removed from cart', context);
                          },
                          child: GestureDetector(
                            onTap: () {
                              final p = detail.product;
                              if (p == null) return;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProductScreen(
                                    product: allProducts.Product(
                                      id: p.id,
                                      name: p.name,
                                      image: p.image,
                                      price: p.price,
                                      category: p.category,
                                    ),
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
                                      Row(
                                        children: [
                                          Text(
                                            "\$${(detail.product?.price ?? 0).toStringAsFixed(2)}",
                                            style: appStyle(16, FontWeight.w700, AppColors.cta),
                                          ),
                                          if (detail.qty != null) ...[
                                            SizedBox(width: 8.w),
                                            Container(
                                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                                              decoration: BoxDecoration(
                                                color: AppColors.primary,
                                                borderRadius: BorderRadius.circular(4.r),
                                              ),
                                              child: Text(
                                                "x${detail.qty}",
                                                style: appStyle(12, FontWeight.w700, Colors.white),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    cartState.savedItems.any((e) => e['id'] == detail.product?.id)
                                        ? Icons.bookmark
                                        : Icons.bookmark_border,
                                    size: 20.sp,
                                    color: cartState.savedItems.any((e) => e['id'] == detail.product?.id)
                                        ? AppColors.primary
                                        : AppColors.textHint,
                                  ),
                                  onPressed: () {
                                    final p = detail.product;
                                    if (p == null || p.id == null) return;
                                    if (cartState.savedItems.any((e) => e['id'] == p.id)) {
                                      _removeSaved(p.id!);
                                      CustomSnackBar.info(context.t.tr('item_removed_from_cart'), context);
                                    } else {
                                      _saveItem(p.id, p.name, p.image, p.price);
                                      CustomSnackBar.info(context.t.tr('save_for_later'), context);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          ),
                        );
                      },
                    ),
                  ),
                  ButtomNavBar(),
                ],
              );
            },
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildSavedItems() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => _state.value = _state.value.copyWith(savedExpanded: !_state.value.savedExpanded),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Row(
                children: [
                  Icon(Icons.bookmark, size: 18.sp, color: AppColors.primary),
                  SizedBox(width: 6.w),
                  Text(
                    context.t.tr('saved_for_later'),
                    style: appStyle(16, FontWeight.w600, AppColors.textPrimary),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    '(${_state.value.savedItems.length})',
                    style: appStyle(14, FontWeight.w400, AppColors.textHint),
                  ),
                  const Spacer(),
                  Icon(
                    _state.value.savedExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 20.sp,
                  ),
                ],
              ),
            ),
          ),
          if (_state.value.savedExpanded) ..._state.value.savedItems.map((item) {
            return Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: CachedNetworkImage(
                      imageUrl: item['image'] ?? '',
                      width: 50.w,
                      height: 50.h,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(
                        width: 50.w,
                        height: 50.h,
                        color: AppColors.surface,
                        child: Icon(Icons.image, size: 20.sp, color: AppColors.textHint),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['name'] ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: appStyle(13, FontWeight.w500, AppColors.textPrimary),
                        ),
                        Text(
                          "\$${(item['price'] as num?)?.toStringAsFixed(2) ?? '0.00'}",
                          style: appStyle(13, FontWeight.w700, AppColors.cta),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      final p = allProducts.Product(
                        id: item['id'],
                        name: item['name'],
                        image: item['image'],
                        price: (item['price'] as num?)?.toDouble(),
                      );
                      Navigator.push(context, MaterialPageRoute(builder: (_) => ProductScreen(product: p)));
                    },
                    child: Text(context.t.tr('move_to_cart')),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
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
          if (_state.value.loadingSuggestions)
            SizedBox(
              height: 180.h,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else if (_state.value.suggestions.isEmpty)
            const SizedBox.shrink()
          else
            SizedBox(
              height: 200.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: _state.value.suggestions.length,
                separatorBuilder: (_, __) => SizedBox(width: 10.w),
                itemBuilder: (context, index) {
                  final item = _state.value.suggestions[index];
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
                              height: 100.h,
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
