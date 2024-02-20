import 'package:flutter/material.dart';
import 'package:ship_link/views/screens/checkOut/check_out.dart';

import '../../../shared/app_style.dart';
import 'check_out_button.dart';

class ButtomNavBar extends StatelessWidget {
  const ButtomNavBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: InkWell(
        onTap: () {},
        child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.76,
            height: 180,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 16),
                      child: TextField(
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(10),
                            filled: true,
                            fillColor: const Color(0xFF242424),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(9),
                                borderSide: BorderSide.none),
                            hintText: 'Enter your promo code',
                            hintStyle:
                                const TextStyle(color: Color(0xFF999999))),
                      ),
                    ),
                    Positioned(
                        top: 15,
                        right: 4,
                        child: GestureDetector(
                          onTap: () {},
                          child: Container(
                            width: 45,
                            height: 49,
                            decoration: BoxDecoration(
                                color: const Color(0xFFA1A1A1),
                                borderRadius: BorderRadius.circular(9)),
                            child: const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.black,
                            ),
                          ),
                        )),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total:",
                        style: appStyle(18, FontWeight.w600, Colors.black),
                      ),
                      Text(
                        "\$ 22.00 ",
                        style: appStyle(18, FontWeight.w600, Colors.black),
                      )
                    ],
                  ),
                ),
                CheckoutButton(
                  text: 'Check Out',
                  ontap: () {
                    Navigator.pushNamed(context, CheckOut.routName);
                  },
                )
              ],
            )),
      ),
    );
  }
}
