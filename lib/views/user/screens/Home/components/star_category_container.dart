import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class BuildStarCategory extends StatelessWidget {
  const BuildStarCategory({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 65,
      height: 65,
      decoration: BoxDecoration(
          color: const Color(0xFF303030),
          borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(17.0),
        child: SvgPicture.asset(
          "assets/icons/star 1.svg",
          height: 10,
          width: 10,
        ),
      ),
    );
  }
}
