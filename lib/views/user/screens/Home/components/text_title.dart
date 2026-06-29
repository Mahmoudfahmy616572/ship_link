import 'package:flutter/material.dart';
import 'package:ship_link/utils/sizer.dart';

class ProductTextTitle extends StatelessWidget {
  const ProductTextTitle({
    super.key,
    required this.textStyle,
    required this.text,
  });
  final TextStyle? textStyle;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 15.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            text,
            style: textStyle,
          )
        ],
      ),
    );
  }
}
