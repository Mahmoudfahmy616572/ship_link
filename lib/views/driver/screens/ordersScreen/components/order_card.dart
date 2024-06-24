// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

import '../../../../shared/app_style.dart';

class OrdersCard extends StatelessWidget {
  OrdersCard({
    super.key,
    required this.status,
    required this.totalPrice,
    required this.name,
    required this.email,
    required this.phoneNumber,
  });
  final String status;
  final String totalPrice;
  final String name;
  final String email;
  final String phoneNumber;
  bool isChecked = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Container(
        //   padding: EdgeInsets.symmetric(
        //       horizontal: MediaQuery.of(context).size.width * 0.02,
        //       vertical: MediaQuery.of(context).size.height * 0.01),
        //   width: MediaQuery.of(context).size.width * 0.92,
        //   height: 40,
        //   decoration: const BoxDecoration(
        //       color: Colors.black,
        //       borderRadius: BorderRadius.only(
        //           topLeft: Radius.circular(10), topRight: Radius.circular(10))),
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //     children: [
        //       Text(
        //         status,
        //         style: appStyle(15, FontWeight.normal, const Color(0xFFCDCDCD)),
        //       ),
        //       Text(
        //         totalPrice,
        //         style: appStyle(15, FontWeight.normal, const Color(0xFFCDCDCD)),
        //       ),
        //     ],
        //   ),
        // ),
        Container(
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
          child: Column(
            children: [
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
            ],
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.02,
        )
      ],
    );
  }
}

class TextWidget extends StatelessWidget {
  const TextWidget({
    super.key,
    required this.text,
    required this.color,
  });

  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: color,
      ),
      child: Text(
        text,
        style: appStyle(15, FontWeight.normal, const Color(0xFFCDCDCD)),
      ),
    );
  }
}
