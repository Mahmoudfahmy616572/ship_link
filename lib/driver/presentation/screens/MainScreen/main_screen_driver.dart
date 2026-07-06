import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/core/constants/services_locators.dart';
import 'package:ship_link/driver/presentation/cubits/acceptOrder/accept_order_cubit.dart';
import 'package:ship_link/driver/presentation/cubits/getAcceptedOrders/get_accepted_order_cubit.dart';
import 'package:ship_link/driver/presentation/cubits/get_user_driver_data/get_userdriver_data_cubit.dart';
import 'package:ship_link/driver/presentation/cubits/get_orders/get_orders_cubit.dart';
import 'package:ship_link/driver/domain/repositories/driver_home_repository.dart';
import 'package:ship_link/driver/presentation/screens/DriverProfile/driver_profile.dart';
import 'package:ship_link/driver/presentation/screens/ordersScreen/ordersScreen.dart';

import 'package:ship_link/core/localization.dart';
import 'package:sliding_clipped_nav_bar/sliding_clipped_nav_bar.dart';

import 'package:ship_link/driver/presentation/screens/DriverHome/driver_home.dart';

class MainScreenDriver extends StatefulWidget {
  const MainScreenDriver({super.key});
  static String routName = '/MainScreenDriver';
  @override
  State<MainScreenDriver> createState() => _MainScreenDriverState();
}

class _MainScreenDriverState extends State<MainScreenDriver> {
  late PageController _pageController;
  final _selectedIndex = ValueNotifier<int>(0);
  DateTime? _lastTabTap;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex.value);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _selectedIndex.dispose();
    super.dispose();
  }

  void switchToTab(int index) {
    final now = DateTime.now();
    if (index == _selectedIndex.value) {
      final isDoubleTap = _lastTabTap != null && now.difference(_lastTabTap!) < const Duration(milliseconds: 500);
      _lastTabTap = isDoubleTap ? null : now;
      if (isDoubleTap) {
        if (index == 0 || index == 1) {
          context.read<GetOrdersCubit>().getOrder();
          context.read<GetAcceptedOrderCubit>().getAcceptedOrder();
        } else if (index == 2) {
          context.read<GetUserdriverDataCubit>().getuserDriverData();
        }
      }
    } else {
      _selectedIndex.value = index;
      _pageController.animateToPage(_selectedIndex.value,
          duration: const Duration(milliseconds: 200), curve: Curves.easeOutQuad);
      _lastTabTap = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = getIt<DriverHomeRepository>();
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
        bottomNavigationBar: ValueListenableBuilder<int>(
          valueListenable: _selectedIndex,
          builder: (context, selectedIndex, _) {
            return SlidingClippedNavBar.colorful(
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
            );
          },
        ),
      ),
    );
  }
}
