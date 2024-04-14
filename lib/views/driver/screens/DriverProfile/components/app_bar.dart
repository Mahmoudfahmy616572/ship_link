import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../shared/app_style.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.00,
          vertical: MediaQuery.of(context).size.height * 0.01),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          InkWell(onTap: () {}, child: const Text("")),
          Text(
            "Driver Profile",
            style: appStyle(18, FontWeight.w600, Colors.white),
          ),
          InkWell(
              onTap: () {},
              child: SvgPicture.asset(
                "assets/icons/Editsvg.svg",
              )),
        ],
      ),
    );
  }
}
