import 'package:flutter/material.dart';

import 'components/body.dart';

class DriverHome extends StatelessWidget {
  const DriverHome({super.key});
  static String routName = '/ProfileDriver';

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFEBEBEB),
      body: Body(),
    );
  }
}
