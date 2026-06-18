// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ship_link/cubits/getFromCart/get_from_cart_cubit.dart';
import 'package:ship_link/views/shared/notification_bell.dart';
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
  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: selectedIndex);
  }

  void onButtonPressed(int index) {
    setState(() {
      selectedIndex = index;
      if (index == 2) {
        BlocProvider.of<GetFromCartCubit>(context).getProductFromCart();
      }
    });
    _pageController.animateToPage(selectedIndex,
        duration: const Duration(milliseconds: 200), curve: Curves.easeOutQuad);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
          children: [
            Column(
              children: <Widget>[
                Expanded(
                  child: PageView(
                    physics: const NeverScrollableScrollPhysics(),
                    controller: _pageController,
                    children: _listOfWidget,
                  ),
                ),
              ],
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const NotificationBell(),
              ),
            ),
          ],
        ),
        bottomNavigationBar: SlidingClippedNavBar.colorful(
          backgroundColor: Colors.black,
          onButtonPressed: onButtonPressed,
          iconSize: 28,
          selectedIndex: selectedIndex,
          barItems: <BarItem>[
            BarItem(
              icon: Icons.home,
              title: 'Home',
              activeColor: Colors.blue,
              inactiveColor: Colors.white,
            ),
            BarItem(
              icon: Icons.search,
              title: 'Search',
              activeColor: Colors.blue,
              inactiveColor: Colors.white,
            ),
            BarItem(
              icon: Icons.shopping_cart,
              title: 'cart',
              activeColor: Colors.blue,
              inactiveColor: Colors.white,
            ),
            BarItem(
              icon: Icons.person,
              title: 'Profile',
              activeColor: Colors.blue,
              inactiveColor: Colors.white,
            ),
          ],
        ));
  }
}

List<Widget> _listOfWidget = <Widget>[
  const HomeScreen(),
  const Search(),
  const Cart(),
  const Profile()
];
