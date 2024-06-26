import 'package:flutter/material.dart';

import '../../../../shared/app_style.dart';
import '../../ordersScreen/components/order_card.dart';

class AcceptedOrderCard extends StatelessWidget {
  const AcceptedOrderCard({
    super.key,
    required this.status,
    required this.name,
    required this.phoneNumber,
    required this.email,
    required this.totalPrice,
  });
  final String status;
  final String name;
  final String phoneNumber;
  final String email;
  final String totalPrice;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.02,
              vertical: MediaQuery.of(context).size.height * 0.01),
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width * 0.92,
          height: MediaQuery.of(context).size.height * 0.25,
          decoration: const BoxDecoration(
              color: Color(0xFF545454),
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10))),
          child: Column(children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white60,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        "status:",
                        style: appStyle(20, FontWeight.w700, Colors.black),
                      ),
                      TextWidget(
                        text: status,
                        color: Colors.green,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Text(
                        "Total Price:",
                        style: appStyle(20, FontWeight.w700, Colors.black),
                      ),
                      TextWidget(
                        text: totalPrice,
                        color: Colors.green,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            TextWidget(
              text: name,
              color: Colors.black,
            ),
            const SizedBox(
              height: 10,
            ),
            TextWidget(
              text: phoneNumber,
              color: Colors.black,
            ),
            const SizedBox(
              height: 10,
            ),
            TextWidget(
              text: email,
              color: Colors.black,
            ),
            const SizedBox(
              height: 20,
            )
          ])),
    );
  }
}
