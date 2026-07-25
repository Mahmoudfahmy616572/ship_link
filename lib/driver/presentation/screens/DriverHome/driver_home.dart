import 'package:flutter/material.dart';

import 'package:ship_link/driver/presentation/screens/DriverHome/components/body.dart';

class DriverHome extends StatefulWidget {
  const DriverHome({super.key});
  static String routName = '/ProfileDriver';

  @override
  State<DriverHome> createState() => _DriverHomeState();
}

class _DriverHomeState extends State<DriverHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: const Body(),
    );
  }
}
