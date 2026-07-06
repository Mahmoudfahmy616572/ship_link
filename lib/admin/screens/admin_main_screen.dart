import 'package:flutter/material.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/widgets/app_style.dart';
import 'package:ship_link/admin/widgets/admin_sidebar.dart';
import 'package:ship_link/admin/screens/admin_dashboard.dart';
import 'package:ship_link/admin/screens/admin_orders.dart';
import 'package:ship_link/admin/screens/admin_drivers.dart';
import 'package:ship_link/admin/screens/admin_products.dart';
import 'package:ship_link/core/utils/sizer.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});
  static String routName = '/admin';

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    AdminDashboard(),
    AdminOrders(),
    AdminDrivers(),
    AdminProducts(),
  ];

  final List<String> _titles = [
    'Dashboard',
    'Orders',
    'Drivers',
    'Products',
  ];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;
    return Scaffold(
      appBar: !isWide
          ? AppBar(
              title: Text(_titles[_selectedIndex]),
              backgroundColor: const Color(0xFF1a1a2e),
            )
          : null,
      body: Row(
        children: [
          AdminSidebar(
            selectedIndex: _selectedIndex,
            onItemSelected: (i) => setState(() => _selectedIndex = i),
          ),
          Expanded(
            child: Container(
              color: AppColors.background,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isWide)
                    Container(
                      padding: EdgeInsets.all(20.w),
                      child: Text(_titles[_selectedIndex],
                          style: appStyle(28, FontWeight.bold, Colors.black87)),
                    ),
                  Expanded(child: _screens[_selectedIndex]),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: !isWide
          ? BottomNavigationBar(
              currentIndex: _selectedIndex,
              type: BottomNavigationBarType.fixed,
              backgroundColor: AppColors.textPrimary,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: Colors.grey,
              onTap: (i) => setState(() => _selectedIndex = i),
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
                BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Orders'),
                BottomNavigationBarItem(icon: Icon(Icons.local_shipping), label: 'Drivers'),
                BottomNavigationBarItem(icon: Icon(Icons.inventory_2), label: 'Products'),
              ],
            )
          : null,
    );
  }
}