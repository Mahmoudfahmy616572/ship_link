import 'package:cached_network_image/cached_network_image.dart';
import 'package:ship_link/localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/constant/colors.dart';
import 'package:ship_link/constant/services_locators.dart';
import 'package:ship_link/cubits/addToCart/add_to_cart_cubit.dart';
import 'package:ship_link/cubits/favourite/favourite_cubit.dart';
import 'package:ship_link/data/models/allProducts/all_products.dart';
import 'package:ship_link/data/models/review/review_model.dart';
import 'package:ship_link/data/services/cartServeices/cart_serveicesimpl.dart';
import 'package:ship_link/data/services/favouriteServices/favourite_services_impl.dart';
import 'package:ship_link/views/shared/snackBar/snack_bar.dart';
import 'package:ship_link/data/services/review/review_service.dart';
import 'package:ship_link/utils/sizer.dart';
import 'package:ship_link/views/shared/product_image_carousel.dart';

import '../../../shared/app_style.dart';
import 'components/add_subtract_btn.dart';
import 'components/button_add_to_cart.dart';
import 'components/rating_row.dart';

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

class _ProductScreenState extends State<ProductScreen>
    with SingleTickerProviderStateMixin {
  int _quantity = 1;
  final _reviewService = ReviewService();
  List<Review> _reviews = [];
  double _avgRating = 0;
  int _reviewCount = 0;
  bool _loadingReviews = true;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    final product = widget.product;
    if (product?.id == null) return;
    try {
      final rating = await _reviewService.getProductRating(product!.id!);
      final reviews = await _reviewService.getReviews(product.id!);
      if (mounted) {
        setState(() {
          _avgRating = (rating['avg'] as num).toDouble();
          _reviewCount = rating['count'] as int;
          _reviews = reviews;
          _loadingReviews = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingReviews = false);
    }
  }

  Widget _buildReviewsSection() {
    final product = widget.product;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(context.t.tr('reviews'),
                style: appStyle(18, FontWeight.w700, AppColors.textPrimary)),
            const Spacer(),
            if (_reviewCount > 0)
              Text('$_reviewCount reviews',
                  style: appStyle(13, FontWeight.w500, AppColors.textSecondary)),
          ],
        ),
        SizedBox(height: 12.h),
        if (_loadingReviews)
          Center(child: Padding(
            padding: EdgeInsets.all(16.w),
            child: CircularProgressIndicator(strokeWidth: 2),
          ))
        else if (_reviews.isEmpty)
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
          ..._reviews.take(3).map((r) => _reviewCard(r)),
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
    final name = review.user?['first_name'] as String? ?? 'Anonymous';
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
          create: (_) => AddToCartCubit(getIt.get<CartServeicesImpl>()),
        ),
        BlocProvider(
          create: (_) =>
              FavouriteCubit(getIt.get<FavouriteServiceImpl>())..getFavourites(),
        ),
      ],
      child: BlocListener<AddToCartCubit, AddToCartState>(
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
                        borderRadius: 20,
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
                  RatingRow(rating: _avgRating, reviewCount: _reviewCount),
                  SizedBox(height: 20.h),
                  Row(
                    children: [
                      Text(context.t.tr('quantity'),
                          style: appStyle(15, FontWeight.w600, AppColors.textPrimary)),
                      const Spacer(),
                      AddOrSubtractButton(
                        ontap: () {
                          setState(() {
                            if (_quantity > 1) _quantity--;
                          });
                        },
                        icon: Icons.remove,
                      ),
                      SizedBox(width: 16.w),
                      Text(
                        _quantity.toString().padLeft(2, '0'),
                        style: appStyle(18, FontWeight.w700, AppColors.textPrimary),
                      ),
                      SizedBox(width: 16.w),
                      AddOrSubtractButton(
                        ontap: () => setState(() => _quantity++),
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
                          quantity: _quantity,
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
                  SizedBox(height: 32.h),
                  _buildReviewsSection(),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
