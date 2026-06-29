import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ship_link/utils/sizer.dart';

class BuildCategoryContainer extends StatelessWidget {
  BuildCategoryContainer({
    super.key,
    required this.img,
  });
  String? img;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.w),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: CachedNetworkImage(
          fit: BoxFit.cover,
          imageUrl: img!,
          errorWidget: (context, url, error) => Center(
              child: Icon(
            Icons.error_outline,
            size: 60.sp,
          )),
        ),
      ),
    );
  }
}
