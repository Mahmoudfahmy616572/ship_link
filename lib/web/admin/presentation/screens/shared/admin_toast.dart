import 'package:flutter/material.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/widgets/app_style.dart';

// نظام إشعارات موحّد للأدمن (success / error / info)
class AdminToast {
  // نعرض إشعار من نوع معين
  static void show(
    BuildContext context,
    String message, {
    AdminToastType type = AdminToastType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final color = type == AdminToastType.success
        ? AppColors.success
        : type == AdminToastType.error
            ? AppColors.error
            : AppColors.info;
    final icon = type == AdminToastType.success
        ? Icons.check_circle_outline
        : type == AdminToastType.error
            ? Icons.error_outline
            : Icons.info_outline;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(message, style: appStyle(14, FontWeight.w500, Colors.white))),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
        duration: duration,
      ),
    );
  }

  static void success(BuildContext context, String message) =>
      show(context, message, type: AdminToastType.success);
  static void error(BuildContext context, String message) =>
      show(context, message, type: AdminToastType.error);
  static void info(BuildContext context, String message) =>
      show(context, message, type: AdminToastType.info);
}

enum AdminToastType { success, error, info }

// ديالوج تأكيد موحّد للحركات الخطيرة
class AdminConfirmDialog {
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    Color confirmColor = AppColors.error,
  }) async {
    final t = context.t;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: appStyle(18, FontWeight.w700, AppColors.textPrimary)),
        content: Text(message, style: appStyle(14, FontWeight.w400, AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(cancelText ?? t.tr('cancel'), style: appStyle(14, FontWeight.w600, AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(confirmText ?? t.tr('confirm'), style: appStyle(14, FontWeight.w600, Colors.white)),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
