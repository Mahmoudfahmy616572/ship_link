import 'package:flutter/material.dart';
import 'package:ship_link/theme/app_bar_theme.dart';
import 'package:ship_link/theme/button_theme.dart';
import 'package:ship_link/theme/text_form_feild.dart';
import 'package:ship_link/theme/text_theme.dart';

class TAppTheme {
  TAppTheme._();
  static ThemeData lightMode = ThemeData(
      useMaterial3: true,
      fontFamily: "Poppins",
      brightness: Brightness.light,
      primaryColor: Colors.white,
      scaffoldBackgroundColor: Colors.white,
      textTheme: TTextTheme.textLightMode,
      elevatedButtonTheme: TButtonTheme.lightbuttonTheme,
      inputDecorationTheme: TTextFormFieldTheme.lightTextFormTheme,
      appBarTheme: TAppBarTheme.lightAppBarTheme);

  static ThemeData darkMode = ThemeData(
      useMaterial3: true,
      fontFamily: "Poppins",
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFFCDCDCD),
      primaryColor: Colors.white,
      textTheme: TTextTheme.textDarkMode,
      elevatedButtonTheme: TButtonTheme.darkbuttonTheme,
      inputDecorationTheme: TTextFormFieldTheme.darkTextFormTheme,
      appBarTheme: TAppBarTheme.darkAppBarTheme);
}
