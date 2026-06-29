import 'package:flutter/material.dart';
import 'package:ship_link/utils/sizer.dart';

class LogoAndIconTopScreen extends StatelessWidget {
  const LogoAndIconTopScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.menu,
              size: 28.sp,
            )),
        Padding(
          padding: EdgeInsets.only(
            right: MediaQuery.of(context).size.width * 0.08,
            top: 15.h,
          ),
          child: Image.asset(
            "assets/images/signin Logo.png",
            fit: BoxFit.cover,
          ),
        ),
        const Text(""),
      ],
    );
  }
}
