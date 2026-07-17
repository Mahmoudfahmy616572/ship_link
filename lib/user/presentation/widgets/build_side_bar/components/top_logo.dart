import 'package:flutter/material.dart';
import 'package:ship_link/core/utils/sizer.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/localization.dart';

import 'package:ship_link/core/widgets/app_style.dart';

class TopLogo extends StatelessWidget {
  const TopLogo({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      SizedBox(height: 18.h),
      Container(
        height: 96.h,
        alignment: Alignment.center,
        child: Image.asset(
          "assets/images/signin Logo.webp",
          height: 96.h,
          fit: BoxFit.contain,
        ),
      ),
      SizedBox(height: 8.h),
      Text(
        context.t.tr('ship_link'),
        style: appStyle(20, FontWeight.w700, AppColors.textPrimary)
            .copyWith(letterSpacing: 0.5),
      ),
      SizedBox(height: 14.h),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Divider(
          height: 1,
          thickness: 1,
          color: AppColors.textPrimary.withOpacity(0.12),
        ),
      ),
    ]);
  }
}
