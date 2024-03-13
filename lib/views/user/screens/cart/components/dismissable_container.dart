// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class DismissibleContainer extends StatelessWidget {
  const DismissibleContainer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration:
          const BoxDecoration(color: Color.fromARGB(255, 252, 190, 190)),
      child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        SvgPicture.asset(
          "assets/icons/Trash.svg",
          color: Colors.red,
        )
      ]),
    );
  }
}
