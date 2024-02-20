import 'package:flutter/material.dart';

import 'components/body.dart';

class Congrates extends StatelessWidget {
  const Congrates({super.key});
  static String routName = '/congrates';
  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xFFCDCDCD),
        body: Body(),
      ),
    );
  }
}
