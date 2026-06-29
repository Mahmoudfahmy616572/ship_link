import 'package:flutter/material.dart';
import 'package:ship_link/utils/sizer.dart';
import 'package:flutter_svg/svg.dart';

class ButtonShoppingbag extends StatelessWidget {
  const ButtonShoppingbag({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(9.w),
        height: 40.h,
        width: 40.w,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9.r), color: Colors.grey),
        child: SvgPicture.asset(
          "assets/icons/shopping_bag icon.svg",
          // ignore: deprecated_member_use
          color: Colors.grey.shade800,
        ));
  }
}
