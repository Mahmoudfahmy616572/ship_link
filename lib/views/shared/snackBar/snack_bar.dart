import 'package:flutter/material.dart';
import 'package:ship_link/utils/sizer.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:ship_link/localization.dart';

class CustomSnackBar {
  static void displayErrorMotionToast(String err, BuildContext context) {
    MotionToast.error(
      title: Text(
        context.t.tr('error'),
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      description: Text(err),
      toastAlignment: Alignment.topCenter,
      barrierColor: Colors.black.withOpacity(0.3),
      animationDuration: const Duration(milliseconds: 500),
      width: 300.w,
      height: 100.h,
      dismissable: false,
    ).show(context);
  }

  static void displaySuccessMotionToast(
      String description, BuildContext context) {
    MotionToast toast = MotionToast.success(
      description: Text(
        description,
        style: TextStyle(fontSize: 12.sp),
      ),
      dismissable: true,
      animationDuration: const Duration(milliseconds: 500),
      barrierColor: Colors.black.withOpacity(0.3),
      opacity: .5,
    );
    toast.show(context);
  }
}
