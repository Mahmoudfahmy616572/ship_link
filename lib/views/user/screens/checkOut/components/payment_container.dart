import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ship_link/views/user/screens/paymentMethod/payment_method.dart';

import '../../../../shared/app_style.dart';

class PaymentContainer extends StatelessWidget {
  const PaymentContainer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      width: double.infinity,
      height: 68,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(9),
          color: const Color(0xFF353537)),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(
          children: [
            Image.asset(
              "assets/images/credit cart.png",
              fit: BoxFit.cover,
              width: 100,
              height: 100,
            ),
            Text(
              '**** **** **** 3947',
              style: appStyle(13, FontWeight.w400, const Color(0xFF808080)),
            ),
          ],
        ),
        GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PaymentMethod()));
            },
            child: SvgPicture.asset("assets/icons/Icon edit.svg"))
      ]),
    );
  }
}
