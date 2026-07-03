import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/constant/services_locators.dart';
import 'package:ship_link/cubitDriver/acceptOrder/accept_order_cubit.dart';
import 'package:ship_link/cubitDriver/getAcceptedOrders/get_accepted_order_cubit.dart';
import 'package:ship_link/cubitDriver/get_user_driver_data/get_userdriver_data_cubit.dart';
import 'package:ship_link/cubitDriver/get_orders/get_orders_cubit.dart';
import 'package:ship_link/data/services/DriverHomeServeices/driver_home_serveices.dart';
import 'package:ship_link/views/driver/screens/DriverProfile/driver_profile.dart';
import 'package:ship_link/views/driver/screens/ordersScreen/ordersScreen.dart';

import 'package:ship_link/localization.dart';
import 'package:sliding_clipped_nav_bar/sliding_clipped_nav_bar.dart';

import '../DriverHome/driver_home.dart';

class MainScreenDriver extends StatefulWidget {
  const MainScreenDriver({super.key});
  static String routName = '/MainScreenDriver';
  @override
  State<MainScreenDriver> createState() => _MainScreenDriverState();
}

class _MainScreenDriverState extends State<MainScreenDriver> {
  late PageController _pageController;
  int selectedIndex = 0;
  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: selectedIndex);
  }

  void switchToTab(int index) {
    setState(() => selectedIndex = index);
    _pageController.animateToPage(selectedIndex,
        duration: const Duration(milliseconds: 200), curve: Curves.easeOutQuad);
  }

  @override
  Widget build(BuildContext context) {
    final service = getIt<DriverHomeServeices>();
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => GetOrdersCubit(service)..getOrder()),
        BlocProvider(create: (_) => GetAcceptedOrderCubit(service)..getAcceptedOrder()),
        BlocProvider(create: (_) => GetUserdriverDataCubit(service)..getuserDriverData()),
        BlocProvider(create: (_) => AcceptOrderCubit(service)),
      ],
      child: Scaffold(
        body: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _pageController,
          children: const [
            DriverHome(),
            OrdersScreen(),
            DriverProfile(),
          ],
        ),
        bottomNavigationBar: SlidingClippedNavBar.colorful(
          backgroundColor: Colors.white,
          onButtonPressed: (i) => switchToTab(i),
          iconSize: 26,
          selectedIndex: selectedIndex,
          barItems: [
            BarItem(
              icon: Icons.home_rounded,
              title: context.t.tr('home_bottom'),
              activeColor: const Color(0xFF2563EB),
              inactiveColor: const Color(0xFF9CA3AF),
            ),
            BarItem(
              icon: Icons.delivery_dining_rounded,
              title: context.t.tr('orders_bottom'),
              activeColor: const Color(0xFF2563EB),
              inactiveColor: const Color(0xFF9CA3AF),
            ),
            BarItem(
              icon: Icons.person_rounded,
              title: context.t.tr('profile_bottom'),
              activeColor: const Color(0xFF2563EB),
              inactiveColor: const Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }
}
