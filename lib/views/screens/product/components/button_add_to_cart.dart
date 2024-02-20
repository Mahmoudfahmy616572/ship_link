import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../shared/app_style.dart';

class BuildButtonAddToCart extends StatelessWidget {
  const BuildButtonAddToCart({
    super.key,
    required this.ontap,
    required this.text,
    required this.img,
  });
  final void Function()? ontap;
  final String text;
  final String img;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: ontap,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.76,
            height: 45,
            decoration: BoxDecoration(
                color: const Color(0xFF242424),
                borderRadius: BorderRadius.circular(12)),
            child: Center(
              child: Text(
                text,
                style: appStyle(20, FontWeight.w700, Colors.white),
              ),
            ),
          ),
        ),
        InkWell(
          onTap: () {},
          child: Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
                color: const Color(0xFF242424),
                borderRadius: BorderRadius.circular(12)),
            child: Center(
                child: SvgPicture.asset(
              img,
            )),
          ),
        )
      ],
    );
  }
}
