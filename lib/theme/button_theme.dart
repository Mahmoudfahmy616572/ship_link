import 'package:flutter/material.dart';
import 'package:ship_link/constant/colors.dart';

import '../views/shared/app_style.dart';

class TButtonTheme {
  TButtonTheme._();
  static ElevatedButtonThemeData lightbuttonTheme = ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    textStyle: appStyle(18, FontWeight.w500, Colors.white),
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10))),
  ));

  static ElevatedButtonThemeData darkbuttonTheme = ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    textStyle: appStyle(18, FontWeight.w500, Colors.white),
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10))),
  ));
}
