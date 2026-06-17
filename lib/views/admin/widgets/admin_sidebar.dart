import 'package:flutter/material.dart';

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
      _MenuItem(Icons.people, 'Users'),
    ];

    return Container(
      width: isWide ? 250 : 80,
      color: const Color(0xFF1a1a2e),
      child: Column(
        children: [
          Container(
            height: 80,
            alignment: Alignment.center,
            child: Text('ShipLink Admin',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: isWide ? 18 : 12,
                    fontWeight: FontWeight.bold)),
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
                    color: selected ? Colors.blueAccent : Colors.grey),
                title: isWide
                    ? Text(item.label,
                        style: TextStyle(
                            color: selected ? Colors.blueAccent : Colors.grey,
                            fontSize: 14))
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
                  isWide ? const Text('Exit', style: TextStyle(color: Colors.red)) : null,
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
