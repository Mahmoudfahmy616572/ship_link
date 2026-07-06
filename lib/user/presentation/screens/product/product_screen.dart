import 'package:cached_network_image/cached_network_image.dart';
import 'package:ship_link/core/localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/constants/services_locators.dart';
import 'package:ship_link/user/presentation/cubits/addToCart/add_to_cart_cubit.dart';
import 'package:ship_link/user/presentation/cubits/favourite/favourite_cubit.dart';
import 'package:ship_link/user/data/models/allProducts/all_products.dart';
import 'package:ship_link/user/data/models/review/review_model.dart';
import 'package:ship_link/user/domain/repositories/cart_repository.dart';
import 'package:ship_link/user/domain/repositories/favourite_repository.dart';
import 'package:ship_link/core/widgets/snackBar/snack_bar.dart';
import 'package:ship_link/user/data/repositories/review_repository_impl.dart';
import 'package:dartz/dartz.dart' hide State;
import 'package:ship_link/core/utils/sizer.dart';
import 'package:ship_link/user/presentation/widgets/product_image_carousel.dart';
import 'package:share_plus/share_plus.dart';

import 'package:ship_link/core/widgets/app_style.dart';
import 'package:ship_link/user/presentation/screens/product/components/add_subtract_btn.dart';
import 'package:ship_link/user/presentation/screens/product/components/button_add_to_cart.dart';
import 'package:ship_link/user/presentation/screens/product/components/rating_row.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({
    super.key,
    this.product,
  });

  static String routName = '/productScreen';
  final Product? product;

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ReviewsData {
  final bool loading;
  final List<Review> reviews;
  final double avgRating;
  final int reviewCount;
  const _ReviewsData({
    this.loading = true,
    this.reviews = const [],
    this.avgRating = 0.0,
    this.reviewCount = 0,
  });
}

class _ProductScreenState extends State<ProductScreen>
    with SingleTickerProviderStateMixin {
  final _reviewService = ReviewRepositoryImpl();
  final _reviewsState = ValueNotifier<_ReviewsData>(const _ReviewsData());

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    final product = widget.product;
    if (product?.id == null) return;
    try {
      final rating = (await _reviewService.getProductRating(product!.id!)).fold((_) => <String, dynamic>{'avg': 0.0, 'count': 0}, (v) => v);
      final reviews = (await _reviewService.getReviews(product.id!)).fold((_) => <Review>[], (v) => v);
      if (mounted) {
        _reviewsState.value = _ReviewsData(
          loading: false,
          reviews: reviews,
          avgRating: (rating['avg'] as num).toDouble(),
          reviewCount: rating['count'] as int,
        );
      }
    } catch (_) {
      if (mounted) _reviewsState.value = const _ReviewsData(loading: false);
    }
  }

  Widget _buildReviewsSection(_ReviewsData rs) {
    final product = widget.product;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(context.t.tr('reviews'),
                style: appStyle(18, FontWeight.w700, AppColors.textPrimary)),
            const Spacer(),
            if (rs.reviewCount > 0)
              Text('${rs.reviewCount} reviews',
                  style: appStyle(13, FontWeight.w500, AppColors.textSecondary)),
          ],
        ),
        SizedBox(height: 12.h),
        if (rs.loading)
          Center(child: Padding(
            padding: EdgeInsets.all(16.w),
            child: CircularProgressIndicator(strokeWidth: 2),
          ))
        else if (rs.reviews.isEmpty)
          Center(
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                children: [
                  Icon(Icons.rate_review_outlined, size: 40.sp, color: AppColors.textHint),
                  SizedBox(height: 8.h),
                  Text(context.t.tr('no_reviews_yet'),
                      style: appStyle(14, FontWeight.w400, AppColors.textSecondary)),
                ],
              ),
            ),
          )
        else
          ...rs.reviews.take(3).map((r) => _reviewCard(r)),
        SizedBox(height: 12.h),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showWriteReview(product?.id ?? 0),
            icon: Icon(Icons.edit_outlined, size: 18.sp),
            label: Text(context.t.tr('write_review')),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _reviewCard(Review review) {
    final name = review.user?['name'] as String? ?? 'Anonymous';
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14.r,
                child: Text(name[0].toUpperCase(),
                    style: TextStyle(fontSize: 12.sp, color: Colors.white)),
              ),
              SizedBox(width: 8.w),
              Text(name, style: appStyle(13, FontWeight.w600, AppColors.textPrimary)),
              const Spacer(),
              Row(
              children: List.generate(5, (i) => Icon(
                i < review.rating ? Icons.star : Icons.star_border,
                size: 14.sp, color: AppColors.starFilled,
              )),
              ),
            ],
          ),
          if ((review.comment ?? '').isNotEmpty) ...[
            SizedBox(height: 6.h),
            Text(review.comment!,
                style: appStyle(13, FontWeight.w400, AppColors.textSecondary)),
          ],
        ],
      ),
    );
  }

  void _showWriteReview(int productId) {
    int rating = 5;
    final commentCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, MediaQuery.of(ctx).viewInsets.bottom + 20.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(context.t.tr('write_review'),
                      style: appStyle(20, FontWeight.w700, AppColors.textPrimary)),
                  SizedBox(height: 16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      final star = i + 1;
                      return IconButton(
                        icon: Icon(
                          star <= rating ? Icons.star : Icons.star_border,
                          color: AppColors.starFilled, size: 36.sp,
                        ),
                        onPressed: () => setSheetState(() => rating = star),
                      );
                    }),
                  ),
                  SizedBox(height: 12.h),
                  TextField(
                    controller: commentCtrl,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: context.t.tr('review_hint'),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  SizedBox(
                    width: double.infinity,
                    height: 48.h,
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await _reviewService.addReview(
                          productId: productId,
                          rating: rating,
                          comment: commentCtrl.text.trim(),
                        );
                        _loadReviews();
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

  void _showAddToCartPopUp(Product product) {
    CustomSnackBar.success(
      '${product.name ?? 'Item'} added to cart — \$${product.price ?? 0}',
      context,
    );
  }

  @override
  Widget build(BuildContext context) {
    Sizer.init(context);
    final product = widget.product;
    if (product == null) {
      return Scaffold(
        body: Center(child: Text(context.t.tr('product_not_found'))),
      );
    }
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AddToCartCubit(getIt.get<CartRepository>()),
        ),
        BlocProvider(
          create: (_) =>
              FavouriteCubit(getIt.get<FavouriteRepository>())..getFavourites(),
        ),
      ],
      child: Builder(
        builder: (ctx) => BlocListener<AddToCartCubit, AddToCartState>(
        listener: (context, state) {
          if (state is AddToCartSuccess) {
            _showAddToCartPopUp(product);
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined, color: AppColors.textPrimary),
                onPressed: () {
                  final id = product.id ?? 0;
                  final link = 'https://shiplink.app/product/$id';
                  SharePlus.instance.share(ShareParams(text: link));
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20.r),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: ProductImageCarousel(
                        imageUrls: product.imageList,
                        borderRadius: 20.r,
                        aspectRatio: 1,
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    "\$${product.price ?? 4}",
                    style: appStyle(28, FontWeight.w700, AppColors.textPrimary),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    product.name ?? "",
                    style: appStyle(22, FontWeight.w600, AppColors.textPrimary),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    product.description ?? "",
                    style: appStyle(14, FontWeight.w400, AppColors.textSecondary),
                  ),
                  SizedBox(height: 16.h),
                  ValueListenableBuilder<_ReviewsData>(
                    valueListenable: _reviewsState,
                    builder: (context, rs, _) => RatingRow(rating: rs.avgRating, reviewCount: rs.reviewCount),
                  ),
                  SizedBox(height: 20.h),
                  ValueListenableBuilder<int>(
                    valueListenable: ctx.read<AddToCartCubit>().quantityNotifier,
                    builder: (context, qty, _) => Column(
                      children: [
                        Row(
                          children: [
                            Text(context.t.tr('quantity'),
                                style: appStyle(15, FontWeight.w600, AppColors.textPrimary)),
                            const Spacer(),
                            AddOrSubtractButton(
                              ontap: () => ctx.read<AddToCartCubit>().decrementQuantity(),
                              icon: Icons.remove,
                            ),
                            SizedBox(width: 16.w),
                            Text(
                              qty.toString().padLeft(2, '0'),
                              style: appStyle(18, FontWeight.w700, AppColors.textPrimary),
                            ),
                            SizedBox(width: 16.w),
                            AddOrSubtractButton(
                              ontap: () => ctx.read<AddToCartCubit>().incrementQuantity(),
                              icon: Icons.add,
                            ),
                          ],
                        ),
                        SizedBox(height: 24.h),
                        Row(
                          children: [
                            Expanded(
                              child: BuildButtonAddToCart(
                                text: context.t.tr('add_to_cart'),
                                id: product.id ?? 0,
                                quantity: qty,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Builder(builder: (context) {
                              final pid = product.id ?? 0;
                              final isFav = context.select<FavouriteCubit, bool>(
                                  (c) => c.isFavourite(pid));
                              return SizedBox(
                                height: 50.h,
                                width: 54.w,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        isFav ? AppColors.cta.withAlpha(25) : AppColors.surface,
                                    foregroundColor:
                                        isFav ? AppColors.cta : AppColors.textHint,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14.r),
                                      side: BorderSide(
                                        color: isFav ? AppColors.cta : AppColors.border,
                                      ),
                                    ),
                                    elevation: 0,
                                    padding: EdgeInsets.zero,
                                    minimumSize: const Size(0, 0),
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  onPressed: () => context
                                      .read<FavouriteCubit>()
                                      .toggleFavourite(pid),
                                  child: Icon(
                                    isFav ? Icons.favorite : Icons.favorite_border,
                                    size: 22.sp,
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32.h),
                  ValueListenableBuilder<_ReviewsData>(
                    valueListenable: _reviewsState,
                    builder: (context, rs, _) => _buildReviewsSection(rs),
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
  }
}
