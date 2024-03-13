import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ship_link/views/user/screens/addShippingAddress/add_shipping_address.dart';

import '../../../../shared/app_style.dart';

class DetailesContainer extends StatelessWidget {
  const DetailesContainer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      width: double.infinity,
      height: 127,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(9),
          color: const Color(0xFF353537)),
      child: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "C.Ronaldo",
              style: appStyle(16, FontWeight.w500, Colors.white),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AddShippingAddress()));
              },
              borderRadius: BorderRadius.circular(30),
              child: SvgPicture.asset(
                "assets/icons/Icon edit.svg",
              ),
            ),
          ],
        ),
        const Divider(
          color: Color(0xFFF0F0F0),
          thickness: 1.5,
        ),
        Text("25 rue Robert Latouche, Nice, 06200, Côte D’azur, Frances",
            style: appStyle(
              14,
              FontWeight.normal,
              const Color(0xFF808080),
            ))
      ]),
    );
  }
}
