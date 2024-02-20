import 'package:flutter/material.dart';
import 'package:ship_link/views/screens/Home/components/body.dart';

import 'components/Drawer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  static String routName = '/homeScreen';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFCDCDCD),
      ),
      body: const Body(),
      drawer: const BuildDrawer(),
    );
  }
}
