import 'package:flutter/material.dart';
import 'package:ship_link/views/shared/build_elevation_button.dart';
import 'package:ship_link/views/screens/congrats/congrates.dart';
import 'package:ship_link/views/shared/app_style.dart';

import 'components/delivery_method.dart';
import 'components/payment_container.dart';
import 'components/shipping_address.dart';
import 'components/total_price.dart';

class CheckOut extends StatelessWidget {
  const CheckOut({super.key});
  static String routName = '/checkOut';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCDCDCD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFCDCDCD),
        title: Text(
          "Check Out",
          style: appStyle(18, FontWeight.w700, Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: SingleChildScrollView(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            textTitle("Shipping Address"),
            const SizedBox(
              height: 10,
            ),
            const ShippingAddressContainer(),
            const SizedBox(
              height: 20,
            ),
            textTitle("Payment"),
            const SizedBox(
              height: 10,
            ),
            const PaymentContainer(),
            const SizedBox(
              height: 20,
            ),
            textTitle("Delivery method"),
            const SizedBox(
              height: 10,
            ),
            const DeliveryMethodContainer(),
            const SizedBox(
              height: 40,
            ),
            const TotalPrice(),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.08,
            ),
            CheckoutButton(
              text: 'Submit Order',
              ontap: () {
                Navigator.pushNamed(context, Congrates.routName);
              },
            )
          ]),
        ),
      ),
    );
  }

  Text textTitle(String text) {
    return Text(
      text,
      style: appStyle(18, FontWeight.w600, const Color(0xFF909090)),
    );
  }
}
