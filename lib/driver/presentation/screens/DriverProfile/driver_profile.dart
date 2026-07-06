import 'package:flutter/material.dart';

import 'package:ship_link/driver/presentation/screens/DriverProfile/components/body.dart';

class DriverProfile extends StatefulWidget {
  const DriverProfile({super.key});
  static String routName = '/DriverProfile';

  @override
  State<DriverProfile> createState() => _DriverProfileState();
}

class _DriverProfileState extends State<DriverProfile> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCDCDCD),
      body: Body(scrollController: _scrollController),
    );
  }
}
