import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ship_link/views/screens/addShippingAddress/add_shipping_address.dart';

import '../../../shared/app_style.dart';

class ShippingAddressContainer extends StatelessWidget {
  const ShippingAddressContainer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
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
              "Ronaldo",
              style: appStyle(18, FontWeight.w800, const Color(0xFFCDCDCD)),
            ),
            InkWell(
              onTap: () {
                Navigator.pushNamed(context, AddShippingAddress.routName);
              },
              borderRadius: BorderRadius.circular(50),
              child: SvgPicture.asset(
                "assets/icons/Icon edit.svg",
                height: 23,
                width: 23,
              ),
            )
          ],
        ),
        const Divider(
          color: Color(0xFFF0F0F0),
          thickness: 0.3,
        ),
        Text(
          "25 rue Robert Latouche, Nice, 06200, Côte D’azur, France",
          style: appStyle(13, FontWeight.normal, const Color(0xFF808080)),
        )
      ]),
    );
  }
}
