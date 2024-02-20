import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:ship_link/views/screens/Home/home_screen.dart';
import 'package:ship_link/views/screens/Profile/profile.dart';
import 'package:ship_link/views/screens/cart/cart.dart';
import 'package:ship_link/views/screens/searchScreen/search.dart';
import 'package:sliding_clipped_nav_bar/sliding_clipped_nav_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);
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
    });
    _pageController.animateToPage(selectedIndex,
        duration: const Duration(milliseconds: 400), curve: Curves.easeOutQuad);
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
          iconSize: 30,
          selectedIndex: selectedIndex,
          barItems: <BarItem>[
            BarItem(
              icon: Ionicons.home,
              title: 'Home',
              activeColor: Colors.blue,
              inactiveColor: Colors.white,
            ),
            BarItem(
              icon: Ionicons.search,
              title: 'Search',
              activeColor: Colors.blue,
              inactiveColor: Colors.white,
            ),
            BarItem(
              icon: Ionicons.cart_sharp,
              title: 'cart',
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
  const HomeScreen(),
  const Search(),
  const Cart(),
  const Profile()
];
