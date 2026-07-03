import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ship_link/constant/colors.dart';
import 'package:ship_link/localization.dart';
import 'package:ship_link/views/shared/snackBar/snack_bar.dart';
import 'package:ship_link/views/user/screens/Home/home_screen.dart';
import 'package:ship_link/views/user/screens/Profile/profile.dart';
import 'package:ship_link/views/user/screens/cart/cart.dart';
import 'package:ship_link/views/user/screens/searchScreen/search.dart';
import 'package:sliding_clipped_nav_bar/sliding_clipped_nav_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  static String routName = '/mainScreen';
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late PageController _pageController;
  int selectedIndex = 0;
  DateTime? _lastBackPress;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: selectedIndex);
  }

  void onButtonPressed(int index) {
    setState(() {
      selectedIndex = index;
    });
    _pageController.animateToPage(selectedIndex,
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
          children: _listOfWidget,
        ),
        bottomNavigationBar: SlidingClippedNavBar.colorful(
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
        ),
      ),
    );
  }
}

List<Widget> _listOfWidget = <Widget>[
  const HomeScreen(),
  const Search(),
  const Cart(),
  const Profile()
];
