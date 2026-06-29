import 'package:flutter/material.dart';

import 'components/body.dart';

class DriverHome extends StatefulWidget {
  const DriverHome({super.key});
  static String routName = '/ProfileDriver';

  @override
  State<DriverHome> createState() => _DriverHomeState();
}

class _DriverHomeState extends State<DriverHome> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: Body(),
    );
  }
}
