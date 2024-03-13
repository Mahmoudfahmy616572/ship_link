import 'package:flutter/material.dart';

import '../../../../shared/app_style.dart';

class TotalPrice extends StatelessWidget {
  const TotalPrice({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      width: double.infinity,
      height: 135,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(9),
          color: const Color(0xFF353537)),
      child:
          Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Order:",
              style: appStyle(18, FontWeight.w600, const Color(0xFF808080)),
            ),
            Text(
              "\$ 195.00",
              style: appStyle(18, FontWeight.w600, const Color(0xFFCDCDCD)),
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Delivery:",
              style: appStyle(18, FontWeight.w600, const Color(0xFF808080)),
            ),
            Text(
              "\$ 30.00",
              style: appStyle(18, FontWeight.w600, const Color(0xFFCDCDCD)),
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Total:",
              style: appStyle(18, FontWeight.w600, const Color(0xFF808080)),
            ),
            Text(
              "\$ 225.00",
              style: appStyle(18, FontWeight.w600, const Color(0xFFCDCDCD)),
            )
          ],
        ),
      ]),
    );
  }
}
