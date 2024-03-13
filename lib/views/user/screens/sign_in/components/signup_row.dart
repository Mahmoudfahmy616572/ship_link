import 'package:flutter/material.dart';
import 'package:ship_link/views/user/screens/signup/sign_up.dart';

import '../../../../shared/app_style.dart';

class SignUpRow extends StatelessWidget {
  const SignUpRow({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "First time here? ",
          style: appStyle(14, FontWeight.w300, Colors.white),
        ),
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, SignUp.routName);
          },
          child: Text(
            "SignUp ",
            style: appStyle(15, FontWeight.w500, Colors.blueAccent),
          ),
        ),
      ],
    );
  }
}
