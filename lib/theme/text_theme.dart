import 'package:flutter/material.dart';

import '../views/shared/app_style.dart';

class TTextTheme {
  TTextTheme._();

  static TextTheme textLightMode = TextTheme(
    //for SignIn &signUp screen
    headlineLarge: appStyle(
      35,
      FontWeight.bold,
      const Color(0xFFEFEFEF),
    ),
    headlineMedium: appStyle(25, FontWeight.w600, Colors.black),
    headlineSmall: appStyle(
      14,
      FontWeight.w300,
      const Color(0xFF6C6C6C),
    ),
    //for HomePage title
    titleLarge: appStyle(24, FontWeight.w700, Colors.white), //last title
    titleMedium: appStyle(20, FontWeight.w600, Colors.black), //first&third
    titleSmall: appStyle(20, FontWeight.w500, Colors.black), //second title
    //for HomePage Card
    bodyLarge: appStyle(19, FontWeight.w700, Colors.white),
    bodyMedium: appStyle(18, FontWeight.w600, Colors.white),
    bodySmall: appStyle(17, FontWeight.w400, Colors.white),
    //for cartPage
    labelLarge: appStyle(19, FontWeight.w500, Colors.black),
    labelMedium: appStyle(18, FontWeight.w500, const Color(0xFF606060)), //title
    labelSmall: appStyle(17, FontWeight.w500, Colors.black), //price
  );
  static TextTheme textDarkMode = TextTheme(
      //for SignIn &signUp screen
      headlineLarge: appStyle(
        35,
        FontWeight.bold,
        const Color(0xFFEFEFEF),
      ),
      headlineMedium: appStyle(25, FontWeight.w600, Colors.black),
      headlineSmall: appStyle(
        14,
        FontWeight.w300,
        const Color(0xFF6C6C6C),
      ),
      //for HomePage title
      titleLarge: appStyle(24, FontWeight.w700, Colors.white), //last title
      titleMedium: appStyle(20, FontWeight.w600, Colors.black), //first&third
      titleSmall: appStyle(20, FontWeight.w500, Colors.black), //second title
      //for HomePage Card
      bodyLarge: appStyle(19, FontWeight.w700, Colors.white),
      bodyMedium: appStyle(18, FontWeight.w600, Colors.white),
      bodySmall: appStyle(17, FontWeight.w400, Colors.white),
      //for cartPage
      labelLarge: appStyle(19, FontWeight.w500, Colors.black),
      labelMedium:
          appStyle(18, FontWeight.w500, const Color(0xFF606060)), //title
      labelSmall: appStyle(17, FontWeight.w500, Colors.black) //price
      );
}
