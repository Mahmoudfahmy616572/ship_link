// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:ship_link/views/screens/cart/components/body.dart';

import '../../shared/app_style.dart';
import 'components/buttom_nav_bar.dart';

class Cart extends StatelessWidget {
  const Cart({super.key});
  static String routName = '/Cart';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const ButtomNavBar(),
      backgroundColor: const Color(0xFFCDCDCD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD9D9D9),
        centerTitle: true,
        title: Text(
          "My Cart",
          style: appStyle(20, FontWeight.w700, Colors.black),
        ),
        automaticallyImplyLeading: false,
      ),
      body: const Body(),
    );
  }
}
