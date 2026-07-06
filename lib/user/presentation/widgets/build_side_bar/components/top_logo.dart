import 'package:flutter/material.dart';
import 'package:ship_link/core/constants/colors.dart';
import 'package:ship_link/core/localization.dart';

import 'package:ship_link/core/widgets/app_style.dart';

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
