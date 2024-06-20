import 'package:flutter/material.dart';

import '../../../../shared/app_style.dart';

class ProfileInfo extends StatelessWidget {
  const ProfileInfo({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          backgroundImage: AssetImage("assets/images/mahmoud.jpg"),
          radius: 45,
        ),
        const SizedBox(
          width: 20,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fahmy',
              style: appStyle(
                18,
                FontWeight.bold,
                const Color(0xFF000000),
              ),
            ),
            Text(
              'Phone Number : +20**********',
              style: appStyle(17, FontWeight.normal, const Color(0xFF000000)),
            ),
          ],
        )
      ],
    );
  }
}
