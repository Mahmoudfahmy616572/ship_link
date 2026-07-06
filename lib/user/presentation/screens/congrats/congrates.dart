import 'package:flutter/material.dart';
import 'package:ship_link/core/constants/colors.dart';

import 'package:ship_link/user/presentation/screens/congrats/components/body.dart';

class Congrates extends StatelessWidget {
  const Congrates({super.key, this.userEmail});
  static String routName = '/congrates';
  final String? userEmail;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Body(userEmail: userEmail),
    );
  }
}
