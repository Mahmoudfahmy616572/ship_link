import 'package:flutter/material.dart';

import 'package:ship_link/driver/presentation/screens/DriverRegister/driver_body.dart';

class DriverRegister extends StatelessWidget {
  const DriverRegister({super.key});
  static String routName = '/driver';
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: DriverBody(),
      ),
    );
  }
}
