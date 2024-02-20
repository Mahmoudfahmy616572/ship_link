import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ButtonShoppingbag extends StatelessWidget {
  const ButtonShoppingbag({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(9),
        height: 40,
        width: 40,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9), color: Colors.grey),
        child: SvgPicture.asset(
          "assets/icons/shopping_bag icon.svg",
          // ignore: deprecated_member_use
          color: Colors.grey.shade800,
        ));
  }
}
