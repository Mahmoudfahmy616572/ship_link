import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CancelBtn extends StatelessWidget {
  const CancelBtn({
    super.key,
    this.onTap,
    required this.width,
    required this.height,
    required this.icon,
  });
  final void Function()? onTap;
  final double width, height;
  final String icon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
            color: const Color(0xFF242424),
            borderRadius: BorderRadius.circular(10)),
        width: width,
        height: height,
        child: Center(
            child: SvgPicture.asset(
          "assets/icons/cancel.svg",
        )),
      ),
    );
  }
}
