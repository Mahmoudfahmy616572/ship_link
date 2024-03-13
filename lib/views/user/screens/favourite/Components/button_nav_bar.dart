import 'package:flutter/material.dart';

import '../../product/components/button_add_to_cart.dart';

class ButtomNavBar extends StatelessWidget {
  const ButtomNavBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: BuildButtonAddToCart(
          ontap: () {},
          text: "Add all to my cart",
          img: "assets/icons/shopping_bag icon.svg"),
    );
  }
}
