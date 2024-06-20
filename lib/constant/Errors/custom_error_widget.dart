import 'package:flutter/material.dart';
import 'package:ship_link/views/shared/app_style.dart';

class CustomErrorWidget extends StatelessWidget {
  const CustomErrorWidget({
    super.key,
    required this.errMessage,
  });
  final String errMessage;

  @override
  Widget build(BuildContext context) {
    return Text(
      errMessage,
      style: appStyle(20, FontWeight.normal, Colors.red),
    );
  }
}
