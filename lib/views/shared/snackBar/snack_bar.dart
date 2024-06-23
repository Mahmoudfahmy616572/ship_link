import 'package:flutter/material.dart';
import 'package:motion_toast/motion_toast.dart';

 class CustomSnackBar {
static void displayErrorMotionToast(String err, BuildContext context) {
    MotionToast.error(
      title: const Text(
        'Error',
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      description: Text(err),
      position: MotionToastPosition.top,
      barrierColor: Colors.black.withOpacity(0.3),
      width: 300,
      height: 80,
      dismissable: false,
    ).show(context);
  }

 static void displaySuccessMotionToast(String description, BuildContext context) {
    MotionToast toast = MotionToast.success(
      description: Text(
        description,
        style: const TextStyle(fontSize: 12),
      ),
      dismissable: true,
      opacity: .5,
    );
    toast.show(context);
  }
}
