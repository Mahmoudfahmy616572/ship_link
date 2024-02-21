import 'package:flutter/material.dart';

import '../views/shared/app_style.dart';

class TButtonTheme {
  TButtonTheme._();
  static ElevatedButtonThemeData lightbuttonTheme = ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF242424),
    foregroundColor: Colors.white,
    textStyle: appStyle(18, FontWeight.w500, Colors.white),
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10))),
  ));

  static ElevatedButtonThemeData darkbuttonTheme = ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF242424),
    foregroundColor: Colors.white,
    textStyle: appStyle(18, FontWeight.w500, Colors.white),
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10))),
  ));
}
