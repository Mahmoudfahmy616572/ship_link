import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class MediaContainer extends StatelessWidget {
  const MediaContainer({
    super.key,
    required this.img,
  });
  final String img;
  @override
  Widget build(BuildContext context) {
    return Container(
      // padding: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
      width: 58,
      height: 39,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(9), color: Colors.white),
      child: Center(child: SvgPicture.asset(img)),
    );
  }
}
