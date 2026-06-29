import 'package:flutter/material.dart';
import 'package:ship_link/utils/sizer.dart';
import 'package:motion_toast/motion_toast.dart';

class CustomSnackBarWidget {
  late final BuildContext context;
  displayErrorMotionToast(String err) {
    MotionToast.error(
      title: const Text(
        'Error',
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      description: Text(err),
      toastAlignment: Alignment.topCenter,
      barrierColor: Colors.black.withOpacity(0.3),
      width: 300.w,
      height: 80.h,
      dismissable: false,
    ).show(context);
  }

  void displaySuccessMotionToast(String description) {
    MotionToast toast = MotionToast.success(
      description: Text(
        description,
        style: TextStyle(fontSize: 12.sp),
      ),
      dismissable: true,
      opacity: .5,
    );
    toast.show(context);
  }
}
