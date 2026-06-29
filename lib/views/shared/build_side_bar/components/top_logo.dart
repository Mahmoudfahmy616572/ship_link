import 'package:flutter/material.dart';
import 'package:ship_link/constant/colors.dart';
import 'package:ship_link/localization.dart';

import '../../app_style.dart';

class TopLogo extends StatelessWidget {
  const TopLogo({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      const SizedBox(
        height: 30,
      ),
      Image.asset("assets/images/signin Logo.png"),
      Text(
        context.t.tr('ship_link'),
        style: appStyle(20, FontWeight.bold, AppColors.textPrimary),
      )
    ]);
  }
}
