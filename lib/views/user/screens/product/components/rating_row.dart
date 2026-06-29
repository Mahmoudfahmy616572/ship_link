import 'package:flutter/material.dart';
import 'package:ship_link/constant/colors.dart';
import 'package:ship_link/utils/sizer.dart';

import '../../../../shared/app_style.dart';

class RatingRow extends StatelessWidget {
  final double rating;
  final int reviewCount;

  const RatingRow({
    super.key,
    this.rating = 0,
    this.reviewCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.star, color: AppColors.starFilled, size: 22.sp),
        SizedBox(width: 8.w),
        Text(
          rating > 0 ? rating.toStringAsFixed(1) : '-',
          style: appStyle(16.sp, FontWeight.w700, Colors.black),
        ),
        SizedBox(width: 16.w),
        Text(
          reviewCount > 0 ? '$reviewCount reviews' : 'No reviews yet',
          style: appStyle(14.sp, FontWeight.normal, Colors.grey),
        ),
      ],
    );
  }
}