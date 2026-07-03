import 'package:flutter/material.dart';
import 'package:ship_link/utils/sizer.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:ship_link/localization.dart';

class CustomSnackBar {
  static void success(String message, BuildContext context) {
    MotionToast.success(
      description: Text(message, style: TextStyle(fontSize: 12.sp)),
      toastDuration: const Duration(seconds: 3),
      toastAlignment: Alignment.topCenter,
      animationDuration: const Duration(milliseconds: 400),
      width: 320.w,
      dismissable: true,
      enableAnimation: true,
    ).show(context);
  }

  static void error(String message, BuildContext context) {
    MotionToast.error(
      title: Text(
        context.t.tr('error'),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      description: Text(message, style: TextStyle(fontSize: 12.sp)),
      toastDuration: const Duration(seconds: 4),
      toastAlignment: Alignment.topCenter,
      animationDuration: const Duration(milliseconds: 400),
      width: 320.w,
      dismissable: false,
      enableAnimation: true,
    ).show(context);
  }

  static void info(String message, BuildContext context) {
    MotionToast.info(
      description: Text(message, style: TextStyle(fontSize: 12.sp)),
      toastDuration: const Duration(seconds: 3),
      toastAlignment: Alignment.topCenter,
      animationDuration: const Duration(milliseconds: 400),
      width: 320.w,
      dismissable: true,
      enableAnimation: true,
    ).show(context);
  }

  @Deprecated('Use success() instead')
  static void displaySuccessMotionToast(String description, BuildContext context) {
    success(description, context);
  }

  @Deprecated('Use error() instead')
  static void displayErrorMotionToast(String err, BuildContext context) {
    error(err, context);
  }
}
