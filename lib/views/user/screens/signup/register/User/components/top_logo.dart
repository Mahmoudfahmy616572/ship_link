import 'package:flutter/material.dart';

import '../../../../../../shared/app_style.dart';

class TopLogo extends StatelessWidget {
  const TopLogo({
    super.key,
    required this.text,
  });
  final String text;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset("assets/images/signin Logo.png"),
        Text(
          text,
          style: appStyle(25, FontWeight.bold, Colors.black),
        ),
        Text(
          "Enter your credentials to access your\n account",
          textAlign: TextAlign.center,
          style: appStyle(13, FontWeight.normal, const Color(0xFF6C6C6C)),
        ),
      ],
    );
  }
}
