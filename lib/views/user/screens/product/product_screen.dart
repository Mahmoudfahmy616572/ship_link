import 'package:flutter/material.dart';
import 'package:ship_link/views/shared/app_style.dart';

import 'components/add_subtract_btn.dart';
import 'components/button_add_to_cart.dart';
import 'components/rating_row.dart';

class ProductScreen extends StatelessWidget {
  const ProductScreen({super.key});
static String routName = '/productScreen';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9D9D9),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 25, right: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.1,
              ),
              SizedBox(
                  width: double.infinity,
                  height: 289,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset(
                      "assets/images/papularty1.png",
                      fit: BoxFit.cover,
                    ),
                  )),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.055,
              ),
              Text(
                "Lorem",
                style: appStyle(22, FontWeight.w600, Colors.black),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "\$ 250",
                    style: appStyle(22, FontWeight.w600, Colors.black),
                  ),
                  Row(
                    children: [
                      AddOrSubtractButton(
                        ontap: () {},
                        icon: Icons.add,
                      ),
                      const SizedBox(
                        width: 12,
                      ),
                      const Text("01",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              letterSpacing: 2)),
                      const SizedBox(
                        width: 12,
                      ),
                      AddOrSubtractButton(
                        ontap: () {},
                        icon: Icons.remove,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              const RaitingRow(),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.09,
              ),
              BuildButtonAddToCart(
                ontap: () {},
                text: "Add to cart",
                img: "assets/icons/saveIcon.svg",
              )
            ],
          ),
        ),
      ),
    );
  }
}
