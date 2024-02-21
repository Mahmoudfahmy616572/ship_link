// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ship_link/views/shared/app_style.dart';

import 'Components/button_nav_bar.dart';
import 'Components/cart.dart';
import 'Components/product_card.dart';

class Favourite extends StatelessWidget {
  const Favourite({super.key});
  static String routName = '/favourite';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const ButtomNavBar(),
      backgroundColor: const Color(0xFFCDCDCD),
      appBar: AppBar(
          backgroundColor: const Color(0xFFD9D9D9),
          actions: [
            InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: SvgPicture.asset(
                  "assets/icons/Cart1.svg",
                  height: 22,
                  width: 22,
                ),
              ),
            )
          ],
          // centerTitle: true,
          title: Text(
            "Favourite",
            style: appStyle(20, FontWeight.w700, Colors.black),
          ),
          leading: InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.all(17),
              child: SvgPicture.asset(
                "assets/icons/search.svg",
              ),
            ),
          )),
      body: Padding(
        padding: const EdgeInsets.only(left: 20.0, right: 20),
        child: ListView.builder(
          itemCount: demoCarts.length,
          itemBuilder: (BuildContext context, int index) {
            return Column(
              children: [
                // SizedBox(
                //   height: MediaQuery.of(context).size.height * 0.05,
                // ),
                Dismissible(
                    key: Key(demoCarts[index].product.toString()),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: const BoxDecoration(color: Color(0xFFFFE6E6)),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SvgPicture.asset(
                              "assets/icons/Trash.svg",
                              color: Colors.red,
                            )
                          ]),
                    ),
                    // onDismissed: (direction) {
                    //   setState(() {
                    //     demoCarts.removeAt(index);
                    //   });
                    // },
                    child: ProductCard(
                      cart: demoCarts[index],
                    )),
              ],
            );
          },
        ),
      ),
    );
  }
}
