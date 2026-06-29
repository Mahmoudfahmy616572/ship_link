import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ship_link/utils/sizer.dart';
import 'package:ship_link/data/models/allProducts/all_products.dart';
import 'package:ship_link/localization.dart';
import 'package:ship_link/views/user/screens/product/product_screen.dart';
import 'package:ship_link/views/shared/app_style.dart';

class OffersBanar extends StatelessWidget {
  const OffersBanar({
    super.key,
    required this.product,
    required this.offerNum,
  });
  final Product product;
  final String offerNum;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width * 0.55;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductScreen(product: product),
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: SizedBox(
          width: width.clamp(180, 260),
          height: 140.h,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15.r),
            child: Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: product.image ?? "",
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[800],
                    child: const Icon(Icons.error_outline, color: Colors.white54),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      const Color(0xFF343434).withOpacity(0.4),
                      const Color(0xFF343434).withOpacity(0.14),
                    ]),
                  ),
                ),
                Positioned(
                  bottom: 5,
                  right: 3,
                  child: Container(
                    padding: EdgeInsets.all(6.w),
                    width: 70.w,
                    height: 30.h,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      context.t.tr('lets_go'),
                      style: appStyle(14, FontWeight.normal, Colors.white),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
                  child: Text.rich(TextSpan(
                    style: const TextStyle(color: Colors.white),
                    children: [
                      TextSpan(
                        text: context.t.tr('get_special_discount'),
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w400),
                      ),
                      TextSpan(
                        text: context.t.tr('offer_up_to'),
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.normal),
                      ),
                      TextSpan(
                        text: offerNum,
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 20.sp,
                        ),
                      ),
                    ],
                  )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
