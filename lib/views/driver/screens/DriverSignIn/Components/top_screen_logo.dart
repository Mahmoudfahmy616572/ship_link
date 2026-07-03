import 'package:flutter/material.dart';
import 'package:ship_link/localization.dart';

import '../../../../shared/app_style.dart';

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
          context.t.tr('login_driver'),
          style: appStyle(25, FontWeight.w600, Colors.black),
        ),
        Text(
          context.t.tr('enter_your_credentials'),
          style: appStyle(14, FontWeight.w300, const Color(0xFF6C6C6C)),
          textAlign: TextAlign.center,
        ),
      ]),
    );
  }
}
