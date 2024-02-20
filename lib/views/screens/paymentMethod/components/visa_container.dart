import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../shared/app_style.dart';
import 'row_card_data.dart';

class VisaContainer extends StatelessWidget {
  const VisaContainer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 333,
      height: 180,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(9),
          color: const Color(0xFF999999)),
      child: Stack(children: [
        const Positioned(
            bottom: 0,
            right: 0,
            child: Image(
              image: AssetImage("assets/images/filter payment card.png"),
            )),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 10),
              child: SvgPicture.asset(
                "assets/icons/visa.svg",
                width: 30,
                height: 30,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 10),
              child: Text.rich(TextSpan(children: [
                TextSpan(
                    text: "* * * *  * * * *  * * * *  ",
                    style: appStyle(22, FontWeight.normal, Colors.white)),
                TextSpan(
                    text: "3425",
                    style: appStyle(22, FontWeight.normal, Colors.white))
              ])),
            ),
            RowCardData(
              name: "Card Holder Name",
              date: "Expiry Date",
              textStyle1: appStyle(15, FontWeight.normal, Colors.white70),
              textStyle2: appStyle(15, FontWeight.normal, Colors.white70),
            ),
            RowCardData(
              name: "Jennyfer Doe",
              date: "05/23",
              textStyle1: appStyle(18, FontWeight.normal, Colors.white),
              textStyle2: appStyle(18, FontWeight.normal, Colors.white),
            ),
          ],
        ),
      ]),
    );
  }
}
