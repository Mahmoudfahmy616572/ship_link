import 'package:flutter/material.dart';

import 'components/body.dart';

class DriverProfile extends StatelessWidget {
  const DriverProfile({super.key});
  static String routName = '/DriverProfile';

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFCDCDCD),
      body: Body(),
    );
  }
}
