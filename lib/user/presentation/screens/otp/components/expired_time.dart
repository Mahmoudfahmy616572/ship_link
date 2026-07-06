import 'package:flutter/material.dart';
import 'package:ship_link/core/localization.dart';

import 'package:ship_link/core/widgets/app_style.dart';
import 'package:ship_link/core/utils/sizer.dart';

Row expiredTime(BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      TweenAnimationBuilder(
        tween: Tween(begin: 30.0, end: 0),
        duration: const Duration(seconds: 30),
        builder: (context, value, child) => Text(
          "00:${value.toInt()}",
          style: appStyle(18, FontWeight.bold, Colors.white),
        ),
        onEnd: () {},
      ),
      Text(
        context.t.tr('sec'),
        style: TextStyle(fontSize: 18.sp, color: Colors.white),
      )
    ],
  );
}
