import 'package:flutter/material.dart';

import 'driver_body.dart';

class DriverRegister extends StatelessWidget {
  const DriverRegister({super.key});
  static String routName = '/driver';
  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xFFCDCDCD),
        body: DriverBody(),
      ),
    );
  }
}
