import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../shared/app_style.dart';

class DeliveryMethodContainer extends StatelessWidget {
  const DeliveryMethodContainer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(9),
          color: const Color(0xFF353537)),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(
          children: [
            Image.asset(
              "assets/images/dhl.png",
              fit: BoxFit.contain,
              width: 70,
              height: 100,
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              'Fast (2-3days)',
              style: appStyle(13, FontWeight.w400, const Color(0xFF808080)),
            ),
          ],
        ),
        SvgPicture.asset("assets/icons/Icon edit.svg")
      ]),
    );
  }
}
