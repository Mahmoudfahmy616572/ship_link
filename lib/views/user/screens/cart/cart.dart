// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import '../../../shared/app_style.dart';
import 'components/body.dart';
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
        elevation: 0,
        backgroundColor: const Color(0xFFD9D9D9),
        title: Text(
          "My Cart",
          style: appStyle(20, FontWeight.w700, Colors.black),
        ),
        automaticallyImplyLeading: true,
      ),
      body: const Body(),
    );
  }
}
