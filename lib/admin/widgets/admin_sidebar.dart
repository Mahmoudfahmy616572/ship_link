import 'package:flutter/material.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/utils/sizer.dart';

class AdminSidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const AdminSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;
    final items = [
      _MenuItem(Icons.dashboard, 'Dashboard'),
      _MenuItem(Icons.receipt_long, 'Orders'),
      _MenuItem(Icons.local_shipping, 'Drivers'),
      _MenuItem(Icons.inventory_2, 'Products'),
    ];

    return Container(
      width: isWide ? 250 : 80,
      color: const Color(0xFF1a1a2e),
      child: Column(
        children: [
          Container(
            height: 80.h,
            alignment: Alignment.center,
            child: Image.asset(
              'assets/logos/admin_logo.png',
              width: isWide ? 60 : 36,
              fit: BoxFit.contain,
            ),
          ),
          const Divider(color: Colors.white24),
          ...items.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            final selected = i == selectedIndex;
            return Container(
              color: selected ? Colors.white12 : null,
              child: ListTile(
                leading: Icon(item.icon,
                    color: selected ? AppColors.primary : AppColors.textDisabled),
                title: isWide
                    ? Text(item.label,
                        style: TextStyle(
                            color: selected ? AppColors.primary : AppColors.textDisabled,
                            fontSize: 14.sp))
                    : null,
                onTap: () => onItemSelected(i),
              ),
            );
          }),
          const Spacer(),
          Container(
            color: Colors.white12,
            child: ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.red),
              title:
                  isWide ? Text(context.t.tr('exit'), style: TextStyle(color: Colors.red)) : null,
              onTap: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  const _MenuItem(this.icon, this.label);
}