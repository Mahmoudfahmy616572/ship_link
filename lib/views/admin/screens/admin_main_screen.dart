import 'package:flutter/material.dart';
import '../../shared/app_style.dart';
import '../widgets/admin_sidebar.dart';
import 'admin_dashboard.dart';
import 'admin_orders.dart';
import 'admin_drivers.dart';
import 'admin_products.dart';

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
              color: const Color(0xFFF5F6FA),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isWide)
                    Container(
                      padding: const EdgeInsets.all(20),
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
              backgroundColor: const Color(0xFF1a1a2e),
              selectedItemColor: Colors.blueAccent,
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
