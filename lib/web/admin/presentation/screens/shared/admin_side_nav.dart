import 'package:flutter/material.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/widgets/app_style.dart';
import 'package:ship_link/web/admin/presentation/screens/shared/admin_theme_mode.dart';

// شريط التنقل الجانبي للأدمن
class AdminSideNav extends StatelessWidget {
  final int selectedIndex;
  final List<NavItem> items;
  final ValueChanged<int> onTap;
  final String userName;
  final bool isDark;

  const AdminSideNav({
    super.key,
    required this.selectedIndex,
    required this.items,
    required this.onTap,
    required this.userName,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final surface = AdminThemeMode.surface(isDark);
    final border = AdminThemeMode.border(isDark);
    final textPrimary = AdminThemeMode.textPrimary(isDark);
    final textSecondary = AdminThemeMode.textSecondary(isDark);
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: surface,
        border: Border(right: BorderSide(color: border)),
      ),
      child: Column(
        children: [
          // لوجو أعلى الشريط
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.local_shipping, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Text('ShipLink Admin', style: appStyle(18, FontWeight.w700, textPrimary)),
              ],
            ),
          ),
          Divider(height: 1, color: border),
          // عناصر التنقل
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: items.asMap().entries.map((entry) {
                final i = entry.key;
                final item = entry.value;
                final isSelected = i == selectedIndex;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  child: Material(
                    color: isSelected ? AppColors.primary.withValues(alpha: 0.12) : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => onTap(i),
                      child: ListTile(
                        leading: Icon(item.icon,
                            color: isSelected ? AppColors.primary : textSecondary, size: 22),
                        title: Text(item.label,
                            style: appStyle(15, FontWeight.w500,
                                isSelected ? AppColors.primary : textPrimary)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Divider(height: 1, color: border),
          // بطاقة المستخدم تحت
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : 'A',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(userName, style: appStyle(14, FontWeight.w500, textPrimary),
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NavItem {
  final IconData icon;
  final String label;
  NavItem(this.icon, this.label);
}
