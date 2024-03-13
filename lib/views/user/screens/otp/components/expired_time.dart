import 'package:flutter/material.dart';

import '../../../../shared/app_style.dart';

Row expiredTime() {
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
      const Text(
        " Sec",
        style: TextStyle(fontSize: 18, color: Colors.white),
      )
    ],
  );
}
