import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../shared/app_style.dart';
import 'profile_image.dart';

class ContentUserInfo extends StatelessWidget {
  const ContentUserInfo({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const ProfileImage(),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.02,
        ),
        Text(
          "Name",
          style: appStyle(17, FontWeight.w600, Colors.white),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              "assets/icons/star 1.svg",
              color: Colors.yellow,
              width: 15,
            ),
            Text("4.9", style: appStyle(15, FontWeight.normal, Colors.white))
          ],
        )
      ],
    );
  }
}
