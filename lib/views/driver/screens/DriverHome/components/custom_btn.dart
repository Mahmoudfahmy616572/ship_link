import 'package:flutter/material.dart';

import '../../../../shared/app_style.dart';

class CustomBtn extends StatelessWidget {
  const CustomBtn({
    super.key,
    this.onTap,
    required this.text,
    required this.width,
    required this.height,
  });
  final void Function()? onTap;
  final String text;
  final double width, height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: const Color(0xFF242424),
          textStyle: appStyle(18, FontWeight.w500, Colors.black),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10))),
        ),
        onPressed: () {},
        child: Text(
          text,
        ),
      ),
    );
  }
}
