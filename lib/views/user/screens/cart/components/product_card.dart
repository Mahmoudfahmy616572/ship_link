import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ship_link/utils/sizer.dart';

import '../../../../shared/app_style.dart';
import '../../favourite/Components/button_shopping.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.img,
    required this.name,
    required this.price,
  });
  final String img;
  final String name;
  final String price;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 120.h,
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFF606060)))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Padding(
                padding: EdgeInsets.all(4.w),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(7.r),
                  child: AspectRatio(
                    
                    aspectRatio: 1.6 / 1.5,
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      imageUrl: img,
                      errorWidget: (context, url, error) => Center(
                          child: Icon(
                        Icons.error_outline,
                        size: 60.sp,
                      )),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 30.w,
              ),
              Container(
                padding: EdgeInsets.only(top: 15.h),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: appStyle(
                          17, FontWeight.w500, const Color(0xFF606060)),
                    ),
                    SizedBox(
                      height: 10.h,
                    ),
                    Text(
                      price,
                      style: appStyle(17, FontWeight.w500, Colors.black),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Text("  "),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ButtonDeleteproduct(),
              SizedBox(
                height: 35.h,
              ),
              const ButtonShoppingbag(),
            ],
          )
        ],
      ),
    );
  }
}
