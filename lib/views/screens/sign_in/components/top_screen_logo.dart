import 'package:flutter/material.dart';

import '../../../shared/app_style.dart';

class TopScreenLogo extends StatelessWidget {
  const TopScreenLogo({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(children: [
        Image.asset("assets/images/signin Logo.png"),
        Text(
          "LOGIN",
          style: appStyle(25, FontWeight.w600, Colors.black),
        ),
        Text(
          "Enter your credentials to access your\n account",
          style: appStyle(14, FontWeight.w300, const Color(0xFF6C6C6C)),
          textAlign: TextAlign.center,
        ),
      ]),
    );
  }
}
