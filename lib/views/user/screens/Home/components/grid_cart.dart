import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ship_link/views/user/screens/product/product_screen.dart';

import '../../../../shared/app_style.dart';

class DesignGridCard extends StatelessWidget {
  const DesignGridCard({
    super.key,
    required this.index,
  });
  final int index;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, ProductScreen.routName);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                color: Colors.transparent,
                height: 240,
                width: 190,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(9),
                  child: Image.asset(
                    [
                      "assets/images/car.png",
                      "assets/images/papularty1.png",
                      "assets/images/papularty2.png",
                      "assets/images/papularty3.png"
                    ][index % 5],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      color: const Color(0xFF606066),
                      borderRadius: BorderRadius.circular(9)),
                  child: SvgPicture.asset(
                    "assets/icons/shopping_bag icon.svg",
                  ),
                ),
              ),
            ],
          ),
          Text.rich(TextSpan(children: [
            TextSpan(
                text: "Lorem\n",
                style: appStyle(17, FontWeight.w400, Colors.white)),
            TextSpan(
                text: "\$ 12.00\n",
                style: appStyle(18, FontWeight.w600, Colors.white))
          ]))
        ],
      ),
    );
  }
}
