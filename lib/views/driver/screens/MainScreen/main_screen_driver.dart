// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:ship_link/views/driver/screens/DriverProfile/driver_profile.dart';
import 'package:ship_link/views/driver/screens/notificationsScreen/notifications.dart';
import 'package:sliding_clipped_nav_bar/sliding_clipped_nav_bar.dart';

import '../DriverHome/driver_home.dart';

class MainScreenDriver extends StatefulWidget {
  const MainScreenDriver({super.key});
  static String routName = '/MainScreenDriver';
  @override
  _MainScreenDriverState createState() => _MainScreenDriverState();
}

class _MainScreenDriverState extends State<MainScreenDriver> {
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
    });
    _pageController.animateToPage(selectedIndex,
        duration: const Duration(milliseconds: 200), curve: Curves.easeOutQuad);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
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
        bottomNavigationBar: SlidingClippedNavBar.colorful(
          backgroundColor: Colors.black,
          onButtonPressed: onButtonPressed,
          iconSize: 28,
          selectedIndex: selectedIndex,
          barItems: <BarItem>[
            BarItem(
              icon: Ionicons.home,
              title: 'Home',
              activeColor: Colors.blue,
              inactiveColor: Colors.white,
            ),
            BarItem(
              icon: Ionicons.notifications,
              title: 'Notifications',
              activeColor: Colors.blue,
              inactiveColor: Colors.white,
            ),
            BarItem(
              icon: Ionicons.person,
              title: 'Profile',
              activeColor: Colors.blue,
              inactiveColor: Colors.white,
            ),
          ],
        ));
  }
}

List<Widget> _listOfWidget = <Widget>[
  const DriverHome(),
  const NotificationScreen(),
  const DriverProfile(),
];
