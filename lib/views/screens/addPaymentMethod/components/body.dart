import 'package:flutter/material.dart';
import 'package:ship_link/views/screens/addShippingAddress/components/build_button.dart';
import 'package:ship_link/views/shared/app_style.dart';

import '../../../shared/text_field.dart';
import 'card_payment_method.dart';

class Body extends StatelessWidget {
  const Body({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CardPaymentMethod(),
            const SizedBox(
              height: 40,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "CardHolder Name",
                  style: appStyle(14, FontWeight.w400, const Color(0xFF6C6C6C)),
                ),
                const SizedBox(
                  height: 5,
                ),
                const BuildTextField(
                  hintText: 'Ex: Bruno Pham',
                  obscureText: false,
                  textInputType: TextInputType.name,
                )
              ],
            ),
            const SizedBox(
              height: 40,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Card Number",
                  style: appStyle(14, FontWeight.w400, const Color(0xFF6C6C6C)),
                ),
                const SizedBox(
                  height: 5,
                ),
                const BuildTextField(
                  hintText: '**** **** **** 3456',
                  obscureText: false,
                  textInputType: TextInputType.number,
                ),
                const SizedBox(
                  height: 40,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "CVV",
                          style: appStyle(
                              14, FontWeight.normal, const Color(0xFF6C6C6C)),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.43,
                          child: const BuildTextField(
                            hintText: "Ex: 123",
                            obscureText: false,
                            textInputType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Expiration Date",
                          style: appStyle(
                              14, FontWeight.normal, const Color(0xFF6C6C6C)),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.43,
                            child: const BuildTextField(
                              hintText: "03/22",
                              obscureText: false,
                              textInputType: TextInputType.datetime,
                            )),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.12,
                ),
                BuildButton(
                  text: "Add New Card",
                  color: const Color(0xFF242424),
                  textStyle: appStyle(15, FontWeight.normal, Colors.white),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
