import 'package:flutter/material.dart';

import 'components/body.dart';

class DriverProfile extends StatelessWidget {
  const DriverProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: const Color(0xFFCDCDCD),
      body: Body(),
    );
  }
}
