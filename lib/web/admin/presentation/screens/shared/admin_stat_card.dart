import 'package:flutter/material.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/widgets/app_style.dart';

class AdminStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  const AdminStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 16),
          Text(value,
              style: appStyle(26, FontWeight.w700, AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text(title,
              style: appStyle(13, FontWeight.w500, AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class AdminSectionTitle extends StatelessWidget {
  final String title;
  const AdminSectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(title, style: appStyle(18, FontWeight.w600, AppColors.textPrimary));
  }
}
