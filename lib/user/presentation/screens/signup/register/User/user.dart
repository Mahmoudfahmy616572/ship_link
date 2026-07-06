import 'package:flutter/material.dart';

import 'package:ship_link/user/presentation/screens/signup/register/User/components/user_body.dart';

class UserRegister extends StatelessWidget {
  const UserRegister({super.key});
  static String routName = '/user';

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xFFCDCDCD),
        body: UserBody(),
      ),
    );
  }
}
