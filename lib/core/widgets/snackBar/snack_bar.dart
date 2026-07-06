import 'package:flutter/material.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/localization.dart';

enum SnackBarType { success, error, info }

class CustomSnackBar {
  static void success(String message, BuildContext context) {
    _show(message, context, type: SnackBarType.success);
  }

  static void error(String message, BuildContext context) {
    _show(message, context, type: SnackBarType.error);
  }

  static void info(String message, BuildContext context) {
    _show(message, context, type: SnackBarType.info);
  }

  @Deprecated('Use success() instead')
  static void displaySuccessMotionToast(String description, BuildContext context) {
    success(description, context);
  }

  @Deprecated('Use error() instead')
  static void displayErrorMotionToast(String err, BuildContext context) {
    error(err, context);
  }

  static void _show(String message, BuildContext context,
      {SnackBarType type = SnackBarType.info}) {
    final (Color bg, IconData icon) = switch (type) {
      SnackBarType.error => (AppColors.error, Icons.error_outline_rounded),
      SnackBarType.success => (AppColors.success, Icons.check_circle_outline_rounded),
      SnackBarType.info => (AppColors.info, Icons.info_outline_rounded),
    };

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(message, maxLines: 2, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
        backgroundColor: bg,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 6, left: 16, right: 16),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        duration: Duration(seconds: message.length < 30 ? 3 : message.length < 80 ? 5 : 7),
        dismissDirection: DismissDirection.horizontal,
      ),
    );
  }
}
