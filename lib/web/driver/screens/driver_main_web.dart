import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ship_link/web/data/services_locators.dart';
import 'package:ship_link/web/driver/cubits/get_orders/get_orders_web_cubit.dart';
import 'package:ship_link/web/driver/cubits/get_accepted_orders/get_accepted_orders_web_cubit.dart';
import 'package:ship_link/web/driver/cubits/get_userdriver_data/get_userdriver_data_web_cubit.dart';
import 'package:ship_link/web/driver/cubits/accept_order/accept_order_web_cubit.dart';
import 'package:ship_link/web/driver/screens/driver_home_web.dart';
import 'package:ship_link/web/driver/screens/driver_orders_web.dart';
import 'package:ship_link/web/driver/screens/driver_profile_web.dart';

class DriverMainScreen extends StatefulWidget {
  const DriverMainScreen({super.key});
  static String routName = '/driver/main';

  @override
  State<DriverMainScreen> createState() => _DriverMainScreenState();
}

class _DriverMainScreenState extends State<DriverMainScreen> {
  int _selectedIndex = 0;

  final _pages = const [
    DriverHomeWeb(),
    DriverOrdersWeb(),
    DriverProfileWeb(),
  ];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 768;
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<GetOrdersWebCubit>()..getOrders()),
        BlocProvider(create: (_) => getIt<GetAcceptedOrdersWebCubit>()..getAcceptedOrders()),
        BlocProvider(create: (_) => getIt<GetUserdriverDataWebCubit>()..getuserData()),
        BlocProvider(create: (_) => getIt<AcceptOrderWebCubit>()),
      ],
      child: Scaffold(
        body: Row(
          children: [
            if (isWide)
              NavigationRail(
                selectedIndex: _selectedIndex,
                onDestinationSelected: (i) => setState(() => _selectedIndex = i),
                labelType: NavigationRailLabelType.all,
                leading: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.local_shipping, color: Colors.white, size: 28),
                      ),
                      const SizedBox(height: 8),
                      const Text('ShipLink', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    ],
                  ),
                ),
                destinations: const [
                  NavigationRailDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: Text('Home')),
                  NavigationRailDestination(icon: Icon(Icons.delivery_dining_outlined), selectedIcon: Icon(Icons.delivery_dining), label: Text('Orders')),
                  NavigationRailDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: Text('Profile')),
                ],
              ),
            Expanded(child: _pages[_selectedIndex]),
          ],
        ),
        bottomNavigationBar: isWide
            ? null
            : NavigationBar(
                selectedIndex: _selectedIndex,
                onDestinationSelected: (i) => setState(() => _selectedIndex = i),
                destinations: const [
                  NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
                  NavigationDestination(icon: Icon(Icons.delivery_dining_outlined), selectedIcon: Icon(Icons.delivery_dining), label: 'Orders'),
                  NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
                ],
              ),
      ),
    );
  }
}
