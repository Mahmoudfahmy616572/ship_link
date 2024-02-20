import 'package:flutter/material.dart';
import 'package:ship_link/views/shared/app_style.dart';

class Delivered extends StatelessWidget {
  const Delivered({super.key});
  static String routName = '/delivered';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFCDCDCD),
        body: Padding(
          padding: const EdgeInsets.only(left: 15, right: 15, top: 20),
          child: ListView.builder(
            itemCount: 3,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 172,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(9),
                        color: const Color(0xFF353537)),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 15, right: 15, top: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Order No238562312",
                                  style: appStyle(16, FontWeight.normal,
                                      const Color(0xFFD7D7D7)),
                                ),
                                Text(
                                  "20/03/2020",
                                  style: appStyle(14, FontWeight.normal,
                                      const Color(0xFF808080)),
                                ),
                              ],
                            ),
                          ),
                          const Divider(
                            color: Color(0xFFF0F0F0),
                            thickness: 1.5,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 15, right: 15, top: 10),
                                child: Text.rich(TextSpan(children: [
                                  TextSpan(
                                      text: "Quantity:  ",
                                      style: appStyle(14, FontWeight.w600,
                                          const Color(0xFF808080))),
                                  TextSpan(
                                      text: "03",
                                      style: appStyle(
                                          14, FontWeight.w600, Colors.white)),
                                ])),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 15, right: 15, top: 10),
                                child: Text.rich(TextSpan(children: [
                                  TextSpan(
                                      text: "Total Amount:  ",
                                      style: appStyle(14, FontWeight.w600,
                                          const Color(0xFF808080))),
                                  TextSpan(
                                      text: "\$150",
                                      style: appStyle(
                                          14, FontWeight.w600, Colors.white)),
                                ])),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 2, right: 15, top: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () {},
                                  child: Container(
                                    width: 116,
                                    height: 36,
                                    decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                            bottomRight: Radius.circular(9),
                                            topRight: Radius.circular(9)),
                                        color: Color(0xFF242424)),
                                    child: Center(
                                      child: Text(
                                        "Detail",
                                        style: appStyle(15, FontWeight.normal,
                                            Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                                Text(
                                  "Delivered",
                                  style: appStyle(15, FontWeight.w400,
                                      const Color(0xFF27AE60)),
                                ),
                              ],
                            ),
                          )
                        ]),
                  ),
                  const SizedBox(
                    height: 20,
                  )
                ],
              );
            },
          ),
        ));
  }
}
