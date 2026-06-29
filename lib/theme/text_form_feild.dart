import 'package:flutter/material.dart';
import 'package:ship_link/utils/sizer.dart';
import 'package:ship_link/constant/colors.dart';

class TTextFormFieldTheme {
  TTextFormFieldTheme._();
  static InputDecorationTheme lightTextFormTheme = InputDecorationTheme(
      contentPadding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 0.h),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.r), borderSide: BorderSide.none),
      hintStyle: TextStyle(color: AppColors.textHint, fontSize: 13.5.sp),
      suffixIconColor: Colors.white,
      prefixIconColor: Colors.white,
      filled: true,
      fillColor: AppColors.searchBg);
  static InputDecorationTheme darkTextFormTheme = InputDecorationTheme(
      contentPadding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 0.h),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4.r), borderSide: BorderSide.none),
      errorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.blue, width: 1),
      ),
      hintStyle: TextStyle(color: AppColors.textHint, fontSize: 13.5.sp),
      suffixIconColor: Colors.white,
      prefixIconColor: Colors.white,
      filled: true,
      fillColor: AppColors.searchBg);
}
