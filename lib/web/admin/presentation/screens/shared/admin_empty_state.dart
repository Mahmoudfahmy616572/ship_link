import 'package:flutter/material.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/widgets/app_style.dart';

// حالة فاضية لما مفيش نتايج في أي قايمة
class AdminEmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final VoidCallback? onRetry;
  const AdminEmptyState({super.key, required this.icon, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 56, color: AppColors.textDisabled),
            const SizedBox(height: 16),
            Text(message, style: appStyle(15, FontWeight.w500, AppColors.textSecondary), textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 16),
                label: Text(t.tr('retry')),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
