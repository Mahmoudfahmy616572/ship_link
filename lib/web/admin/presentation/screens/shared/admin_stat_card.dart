import 'package:flutter/material.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/widgets/app_style.dart';
import 'package:ship_link/web/admin/presentation/screens/shared/admin_theme_mode.dart';

class AdminStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;
  const AdminStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary = AdminThemeMode.textPrimary(isDark);
    final textSecondary = AdminThemeMode.textSecondary(isDark);
    final surface = AdminThemeMode.surface(isDark);
    final border = AdminThemeMode.border(isDark);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 16),
          Text(value, style: appStyle(26, FontWeight.w700, textPrimary)),
          const SizedBox(height: 4),
          Text(title, style: appStyle(13, FontWeight.w500, textSecondary)),
        ],
      ),
    );
  }
}

class AdminSectionTitle extends StatelessWidget {
  final String title;
  final bool isDark;
  const AdminSectionTitle(this.title, {super.key, this.isDark = false});

  @override
  Widget build(BuildContext context) {
    return Text(title, style: appStyle(18, FontWeight.w600, AdminThemeMode.textPrimary(isDark)));
  }
}
