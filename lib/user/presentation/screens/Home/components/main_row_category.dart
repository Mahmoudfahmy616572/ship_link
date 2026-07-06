import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ship_link/core/utils/sizer.dart';
import 'package:ship_link/user/data/models/allProducts/all_products.dart';
import 'package:ship_link/user/presentation/screens/product/product_screen.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/widgets/app_style.dart';

class BuildCategoryMainRow extends StatelessWidget {
  const BuildCategoryMainRow({super.key, required this.topSellers});

  final List<Product> topSellers;

  @override
  Widget build(BuildContext context) {
    final cardWidth = MediaQuery.of(context).size.width * 0.4;
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.only(left: 12.w),
      itemCount: topSellers.length,
      itemBuilder: (context, index) {
        final product = topSellers[index];
        return GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductScreen(product: product))),
          child: Container(
            width: cardWidth,
            margin: EdgeInsets.only(right: 12.w, bottom: 4.h),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14.r),
              boxShadow: [BoxShadow(color: AppColors.cardShadow, blurRadius: 6, offset: const Offset(0, 3))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(14.r)),
                  child: AspectRatio(
                    aspectRatio: 1.1,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(imageUrl: product.image ?? "", fit: BoxFit.cover, errorWidget: (_, __, ___) => Container(color: Colors.grey[800])),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 40.h,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.transparent, Colors.black.withValues(alpha: 0.6)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ),
                        Positioned(bottom: 6, left: 6, child: _RatingBadge(rating: (index % 5) + 1)),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(8.w, 8.h, 8.w, 4.h),
                  child: Text(product.name ?? "", maxLines: 1, overflow: TextOverflow.ellipsis, style: appStyle(13, FontWeight.w600, AppColors.textPrimary)),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(8.w, 0.h, 8.w, 8.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("\$${product.price?.toStringAsFixed(0) ?? "0"}", style: appStyle(15, FontWeight.w700, AppColors.cta)),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4.r)),
                        child: Text("${(index % 5) + 1}.0", style: appStyle(10, FontWeight.w500, Colors.greenAccent)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RatingBadge extends StatelessWidget {
  final int rating;
  const _RatingBadge({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(6.r)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...List.generate(rating, (_) => Icon(Icons.star, size: 10.sp, color: AppColors.starFilled)),
          ...List.generate(5 - rating, (_) => Icon(Icons.star_border, size: 10.sp, color: Colors.white38)),
        ],
      ),
    );
  }
}
