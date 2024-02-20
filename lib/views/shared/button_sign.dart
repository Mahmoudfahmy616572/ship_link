import 'package:flutter/material.dart';
import 'package:ship_link/views/shared/app_style.dart';

class BuildButton extends StatelessWidget {
  const BuildButton({
    super.key,
    required this.text,
    required this.color,
    this.ontap,
  });
  final String text;
  final Color? color;
  final void Function()? ontap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ontap,
      child: Container(
        width: double.infinity,
        height: 40,
        decoration:
            BoxDecoration(color: color, borderRadius: BorderRadius.circular(9)),
        child: Center(
          child: Text(
            text,
            style: appStyle(20, FontWeight.w600, Colors.black),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
