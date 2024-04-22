import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:ship_link/views/user/screens/MainScreen/main_screen.dart';
import 'package:ship_link/views/user/screens/order/order.dart';

import '../../../../shared/app_style.dart';
import '../../../../shared/build_elevation_button.dart';

class Body extends StatelessWidget {
  const Body({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Column(children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.08,
        ),
        const Center(
          child: Text(
            "SUCCESS!",
            textAlign: TextAlign.center,
            style: TextStyle(
                letterSpacing: 3,
                fontSize: 28,
                fontWeight: FontWeight.w500,
                color: Colors.black),
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.02,
        ),
        Lottie.asset(
          "assets/json/deleivery.json",
          fit: BoxFit.fill,
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.1,
        ),
        Text.rich(
          TextSpan(
              style: appStyle(16, FontWeight.normal, Colors.black),
              children: const [
                TextSpan(text: "Your order will be delivered soon.\n"),
                TextSpan(text: "Thank you for choosing our app!")
              ]),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.1,
        ),
        CheckoutButton(
          text: "Track your orders",
          ontap: () {
            Navigator.pushNamed(context, Order.routName);
          },
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.02,
        ),
        CheckoutButton(
          text: "Back To Home",
          ontap: () {
            Navigator.pushReplacementNamed(context, MainScreen.routName);
          },
        )
      ]),
    );
  }
}
