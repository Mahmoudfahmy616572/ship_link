import 'package:flutter/material.dart';
import 'package:ship_link/utils/sizer.dart';
import 'package:flutter_svg/svg.dart';

class BuildStarCategory extends StatelessWidget {
  const BuildStarCategory({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width * 0.16;
    return Container(
      width: size.clamp(50, 65),
      height: size.clamp(50, 65),
      decoration: BoxDecoration(
          color: const Color(0xFF303030),
          borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(17.w),
        child: SvgPicture.asset(
          "assets/icons/star 1.svg",
        ),
      ),
    );
  }
}
