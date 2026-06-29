import 'package:flutter/material.dart';
import 'package:ship_link/constant/colors.dart';

ThemeData themeData() {
  return ThemeData(
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Muli',
      primarySwatch: Colors.blue,
      visualDensity: VisualDensity.adaptivePlatformDensity);
}
