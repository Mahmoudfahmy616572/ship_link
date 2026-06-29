import 'package:flutter/material.dart';
import 'package:ship_link/constant/colors.dart';

import '../views/shared/app_style.dart';

class TAppBarTheme {
  TAppBarTheme._();
  static AppBarTheme lightAppBarTheme = AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: AppColors.background,
      titleTextStyle: appStyle(20, FontWeight.w700, Colors.black));

  static AppBarTheme darkAppBarTheme = AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: AppColors.background,
      titleTextStyle: appStyle(20, FontWeight.w700, Colors.black));
}
