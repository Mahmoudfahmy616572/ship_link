import 'package:flutter/material.dart';
import 'package:ship_link/constant/colors.dart';

import 'components/body.dart';

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
