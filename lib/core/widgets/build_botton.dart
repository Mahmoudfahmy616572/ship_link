import 'package:flutter/material.dart';

class BuildButton extends StatelessWidget {
  const BuildButton({
    super.key,
    required this.text,
    required this.color,
    this.ontap,
    this.textStyle,
  });
  final String text;
  final Color? color;
  final void Function()? ontap;
  final TextStyle? textStyle;
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
            style: textStyle,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}