import 'package:flutter/material.dart';
import 'package:ship_link/utils/sizer.dart';

import '../../../../shared/app_style.dart';

class NameAndPrice extends StatelessWidget {
  const NameAndPrice({
    super.key,
    required this.title,
    required this.price,
  });
  final String title;
  final String price;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 15.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: appStyle(17, FontWeight.w500, const Color(0xFF606060)),
          ),
          SizedBox(
            height: 10.h,
          ),
          Text(
            price,
            style: appStyle(17, FontWeight.w500, Colors.black),
          ),
        ],
      ),
    );
  }
}
