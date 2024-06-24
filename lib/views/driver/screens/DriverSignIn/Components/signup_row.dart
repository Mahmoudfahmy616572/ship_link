import 'package:flutter/material.dart';

import '../../../../shared/app_style.dart';
import '../../DriverRegister/driver_register.dart';

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
            Navigator.pushNamed(context, DriverRegister.routName);
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
