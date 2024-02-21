import 'package:flutter/material.dart';

import '../views/shared/app_style.dart';

class TAppBarTheme {
  TAppBarTheme._();
  static AppBarTheme lightAppBarTheme = AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: const Color(0xFFD9D9D9),
      titleTextStyle: appStyle(20, FontWeight.w700, Colors.black));

  static AppBarTheme darkAppBarTheme = AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: const Color(0xFFD9D9D9),
      titleTextStyle: appStyle(20, FontWeight.w700, Colors.black));
}
