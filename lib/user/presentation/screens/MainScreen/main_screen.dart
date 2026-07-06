import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/localization.dart';
import 'package:ship_link/core/widgets/snackBar/snack_bar.dart';
import 'package:ship_link/user/presentation/screens/Home/home_screen.dart';
import 'package:ship_link/user/presentation/screens/Profile/profile.dart';
import 'package:ship_link/user/presentation/screens/cart/cart.dart';
import 'package:ship_link/user/presentation/screens/searchScreen/search.dart';
import 'package:sliding_clipped_nav_bar/sliding_clipped_nav_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  static String routName = '/mainScreen';
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late PageController _pageController;
  DateTime? _lastBackPress;
  final _selectedIndexNotifier = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _selectedIndexNotifier.dispose();
    super.dispose();
  }

  void onButtonPressed(int index) {
    _selectedIndexNotifier.value = index;
    _pageController.animateToPage(index,
        duration: const Duration(milliseconds: 200), curve: Curves.easeOutQuad);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_lastBackPress == null ||
            DateTime.now().difference(_lastBackPress!) >
                const Duration(seconds: 2)) {
          _lastBackPress = DateTime.now();
          CustomSnackBar.info(context.t.tr('press_back_again_exit'), context);
        } else {
          exit(0);
        }
      },
      child: Scaffold(
        body: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _pageController,
          children: const [
            HomeScreen(),
            Search(),
            Cart(),
            Profile(),
          ],
        ),
        bottomNavigationBar: ValueListenableBuilder<int>(
          valueListenable: _selectedIndexNotifier,
          builder: (context, selectedIndex, _) {
            return SlidingClippedNavBar.colorful(
              backgroundColor: AppColors.navbarBg,
              onButtonPressed: onButtonPressed,
              iconSize: 28,
              selectedIndex: selectedIndex,
              barItems: <BarItem>[
                BarItem(
                  icon: Icons.home,
                  title: context.t.tr('home'),
                  activeColor: AppColors.navbarIconActive,
                  inactiveColor: AppColors.navbarIconInactive,
                ),
                BarItem(
                  icon: Icons.search,
                  title: context.t.tr('search'),
                  activeColor: AppColors.navbarIconActive,
                  inactiveColor: AppColors.navbarIconInactive,
                ),
                BarItem(
                  icon: Icons.shopping_cart,
                  title: context.t.tr('cart'),
                  activeColor: AppColors.navbarIconActive,
                  inactiveColor: AppColors.navbarIconInactive,
                ),
                BarItem(
                  icon: Icons.person,
                  title: context.t.tr('profile'),
                  activeColor: AppColors.navbarIconActive,
                  inactiveColor: AppColors.navbarIconInactive,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
