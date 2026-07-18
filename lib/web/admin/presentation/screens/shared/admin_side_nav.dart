import 'package:flutter/material.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/widgets/app_style.dart';

// ده السايد بار بتاع لوحة الأدمن، بيتحط على الشاشات الكبيرة على اليسار
class AdminSideNav extends StatelessWidget {
  final int selectedIndex;
  final List<NavItem> items;
  final ValueChanged<int> onTap;
  final String userName;

  const AdminSideNav({
    super.key,
    required this.selectedIndex,
    required this.items,
    required this.onTap,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          // اللوجو واسم اللوحة فوق
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
                Text('ShipLink Admin', style: appStyle(18, FontWeight.w700, AppColors.textPrimary)),
              ],
            ),
          ),
          const Divider(height: 1),
          // قائمة التنقل
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
                    color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => onTap(i),
                      child: ListTile(
                        leading: Icon(item.icon,
                            color: isSelected ? AppColors.primary : const Color(0xFF6B7280), size: 22),
                        title: Text(item.label,
                            style: appStyle(15, FontWeight.w500,
                                isSelected ? AppColors.primary : const Color(0xFF374151))),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1),
          // بطاقة اسم الأدمن تحت
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
                  child: Text(userName, style: appStyle(14, FontWeight.w500, AppColors.textPrimary),
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
